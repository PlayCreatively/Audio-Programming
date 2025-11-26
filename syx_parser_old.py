import sys
import json


def parse_dx7_voice(voice_data, slot_number):
    """
    Parse a single 128-byte DX7 voice structure into a dictionary.
    Mapping based on standard Yamaha DX7 Packed Format.
    """
    if len(voice_data) != 128:
        raise ValueError(f"Invalid voice data length: {len(voice_data)} bytes (expected 128)")

    voice = {
        "slot": slot_number + 1,
        "name": "",
        "operators": [],
        "global": {}
    }

    # --- 1. Parse Operators (stored 6 down to 1) ---
    # Each operator is 17 bytes.
    # Op 6 starts at 0, Op 5 at 17, ..., Op 1 at 85.
    for op_num in range(6, 0, -1):
        offset = (6 - op_num) * 17
        ops_data = voice_data[offset:offset + 17]

        # Byte 11: Scale Curves (Packed) -> Bits 0-1: Left Curve, Bits 2-3: Right Curve
        scale_byte = ops_data[11]
        scale_left_curve = scale_byte & 0x03
        scale_right_curve = (scale_byte >> 2) & 0x03

        # Byte 12: Detune & Rate Scaling (Packed) -> Bits 0-2: RS, Bits 3-6: Detune
        det_rs_byte = ops_data[12]
        rate_scale = det_rs_byte & 0x07
        detune = (det_rs_byte >> 3) & 0x0F  # 0–14, center 7 (15 normally unused)

        # Byte 13: Velocity & AMS (Packed) -> Bits 0-1: AMS, Bits 2-4: Velocity
        # Dexed/standard: Bits 0-1: AMS (0-3), Bits 2-4: KVS (0-7).
        sens_byte = ops_data[13]
        ams = sens_byte & 0x03
        kvs = (sens_byte >> 2) & 0x07

        # Byte 15: Mode & Coarse (Packed) -> Bit 0: Mode, Bits 1-5: Coarse
        mode_byte = ops_data[15]
        mode = mode_byte & 0x01  # 0 = Ratio, 1 = Fixed
        coarse = (mode_byte >> 1) & 0x1F

        op_params = {
            "id": op_num,
            "eg_rates": [ops_data[0], ops_data[1], ops_data[2], ops_data[3]],
            "eg_levels": [ops_data[4], ops_data[5], ops_data[6], ops_data[7]],
            "break_point": ops_data[8],
            "scale_left_depth": ops_data[9],
            "scale_right_depth": ops_data[10],
            "scale_left_curve": scale_left_curve,
            "scale_right_curve": scale_right_curve,
            "rate_scaling": rate_scale,
            "detune": detune - 7,  # Normalize to -7 to +7
            "ams": ams,
            "velocity_sensitivity": kvs,
            "output_level": ops_data[14],
            "osc_mode": "fixed" if mode else "ratio",
            "freq_coarse": coarse,
            "freq_fine": ops_data[16],
        }
        voice["operators"].append(op_params)

    # --- 2. Parse Pitch EG (Bytes 102-109) ---
    # 4 Rates then 4 Levels
    peg_data = voice_data[102:110]
    voice["global"]["pitch_eg_rates"] = [peg_data[0], peg_data[1], peg_data[2], peg_data[3]]
    voice["global"]["pitch_eg_levels"] = [peg_data[4], peg_data[5], peg_data[6], peg_data[7]]

    # --- 3. Parse Algorithm & Feedback (Bytes 110-111) ---
    # Byte 110: Algorithm (0-31)
    voice["global"]["algorithm"] = voice_data[110] + 1  # 1-32 convention

    # Byte 111: Feedback (bits 0-2) & OSC Sync (bit 3)
    fb_sync_byte = voice_data[111]
    voice["global"]["feedback"] = fb_sync_byte & 0x07
    voice["global"]["osc_key_sync"] = bool((fb_sync_byte >> 3) & 0x01)

    # --- 4. Parse LFO (Bytes 112-116) ---
    voice["global"]["lfo"] = {
        "speed": voice_data[112],
        "delay": voice_data[113],
        "pm_depth": voice_data[114],
        "am_depth": voice_data[115],
    }

    # Byte 116: Packed LFO bits
    # Bit 0: Sync, Bits 1-3: Wave (0-5), Bits 4-6: PMS (0-7), Bit 7 unused
    lfo_packed = voice_data[116]
    voice["global"]["lfo"]["sync"] = bool(lfo_packed & 0x01)
    voice["global"]["lfo"]["wave"] = (lfo_packed >> 1) & 0x07
    voice["global"]["lfo"]["pms"] = (lfo_packed >> 4) & 0x07

    # --- 5. Transpose (Byte 117) ---
    voice["global"]["transpose"] = voice_data[117] - 24  # 24 is usually middle C (C3)

    # --- 6. Voice Name (Bytes 118-127) ---
    try:
        name_bytes = voice_data[118:128]
        voice["name"] = name_bytes.decode("ascii", errors="ignore").strip()
    except Exception:
        voice["name"] = "UNKNOWN"

    return voice


def parse_sysex_file(file_path, output_path):
    try:
        with open(file_path, "rb") as f:
            data = f.read()

        file_size = len(data)
        voice_payload = None

        # Dexed Logic: 4104 bytes = SysEx (6-byte header, 4096 payload, 1 checksum, F7)
        # 4096 bytes = raw payload only.
        if file_size == 4104:
            print("Detected Standard SysEx (4104 bytes). Stripping header & trailer.")
            # Skip 6-byte header and last 2 bytes (checksum + F7)
            voice_payload = data[6:4102]
        elif file_size == 4096:
            print("Detected Raw Voice Data (4096 bytes).")
            voice_payload = data
        else:
            print(f"Warning: File size is {file_size}. Attempting to locate valid 4096-byte payload...")
            # Try to find the bulk dump header
            header = b"\xF0\x43\x00\x09\x20\x00"
            start_idx = data.find(header)
            if start_idx != -1 and start_idx + 6 + 4096 <= file_size:
                voice_payload = data[start_idx + 6:start_idx + 6 + 4096]
            elif file_size >= 4096:
                # Last ditch: just take the first 4096 bytes
                voice_payload = data[:4096]
            else:
                raise ValueError("Could not find valid 4096 byte voice data.")

        if voice_payload is None or len(voice_payload) < 4096:
            raise ValueError(f"Payload too short: {len(voice_payload) if voice_payload else 0} bytes")

        bank_data = []

        # Iterate through 32 voices
        for i in range(32):
            start = i * 128
            end = start + 128
            chunk = voice_payload[start:end]
            if len(chunk) != 128:
                raise ValueError(f"Voice {i} chunk size is {len(chunk)} bytes, expected 128")
            parsed_voice = parse_dx7_voice(chunk, i)
            bank_data.append(parsed_voice)

        # Write to JSON
        with open(output_path, "w", encoding="utf-8") as out_f:
            json.dump(bank_data, out_f, indent=2)

        print(f"Successfully parsed 32 voices to {output_path}")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_syx.py <input.syx> [output.json]")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else "patches.json"
        parse_sysex_file(input_file, output_file)
