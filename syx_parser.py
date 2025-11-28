import sys
import json
import math
import re

# --- DX7 CONVERSION HELPERS ---

def dx7_level_to_amp(raw_val):
    """
    DX7 Levels (0-99) are exponential.
    ~ -0.75dB per step. 
    Returns: 0.0 to 1.0
    """
    if raw_val == 0: return 0.0
    # Formula: 2 ^ ((val - 99) / 8)
    # 99 -> 1.0, 91 -> 0.5, etc.
    return 2.0 ** ((raw_val - 99.0) / 8.0)

def dx7_rate_to_duration(raw_val):
    """
    DX7 Rates (0-99) to Seconds.
    This is a rough approximation of the DX7 lookup table.
    99 = Instant (~0ms)
    0 = Infinite (~forever)
    Typical fast attack (R=70) is ~50ms.
    """
    if raw_val >= 99: return 0.0
    if raw_val == 0: return sys.float_info.max  # Effectively infinite for envelopes
    
    longest_time = 14.0 # seconds for R=0
    
    # Heuristic formula to match the exponential curve of DX7 timing
    # T = 14 * (0.5 ^ (R / 6.0)) roughly matches behavior
    # The power function returns a value between 0.0 and 1.0.
    # We multiply by 14.0 to scale this to real-world seconds.
    # Without this, the longest possible envelope stage would be only 1 second.
    return longest_time * (0.5 ** (raw_val / 6.0))

def get_dx7_algorithm(algo_index, feedback_index=0.0, out_level=[1.0]*6):
    """
    Returns the connection matrix and output mixer for a specific DX7 algorithm.

    Args:
        algo_index (int): 1 to 32.
        feedback_val (float): The amount of feedback (0.0 to 1.0 or higher) 
                              to apply to the algorithm's designated feedback loop.
                              
    Returns:
        tuple: (wiring_matrix, out_mixer)
            wiring_matrix (list[float]): Flat 36-element array (6x6) for SuperCollider.
                                         Row = Destination (Carrier), Col = Source (Modulator).
            out_mixer (list[float]): 6-element array. 1.0 if operator goes to Output, else 0.
    """
    
    # Validate index
    if not (1 <= algo_index <= 32):
        raise ValueError("Algorithm index must be between 1 and 32")

    # DX7 Algorithm Definitions
    # Format: {
    #   "conns": [(src, dst), ...],  -> Modulator (src) modulates Carrier (dst)
    #   "outs": [op_id, ...],        -> Operators that are heard directly
    #   "fb": op_id                  -> Operator that feeds back on itself
    # }
    # Note: Using Standard DX7 Op Numbering (1-6). 
    # 1 is usually the bottom-most operator in charts.
    
    algos = {
        1:  {"conns": [(6,5), (5,4), (4,3), (2,1)], "outs": [1, 3], "fb": (6,6)},
        2:  {"conns": [(6,5), (5,4), (4,3), (2,1)], "outs": [1, 3], "fb": (2,2)},
        3:  {"conns": [(6,5), (5,4), (3,2), (2,1)], "outs": [1, 4], "fb": (6,6)},
        4:  {"conns": [(6,5), (5,4), (3,2), (2,1)], "outs": [1, 4], "fb": (4,6)},
        5:  {"conns": [(6,5), (4,3), (2,1)], "outs": [1, 3, 5], "fb": (6,6)},
        6:  {"conns": [(6,5), (4,3), (2,1)], "outs": [1, 3, 5], "fb": (5,6)},
        7:  {"conns": [(6,5), (5,3), (4,3), (2,1)], "outs": [1, 3], "fb": (6,6)},
        8:  {"conns": [(6,5), (5,3), (4,3), (2,1)], "outs": [1, 3], "fb": (4,4)},
        9:  {"conns": [(6,5), (5,3), (4,3), (2,1)], "outs": [1, 3], "fb": (2,2)},
        10: {"conns": [(3,2), (2,1), (6,4), (5,4)], "outs": [4, 1], "fb": (3,3)},
        11: {"conns": [(3,2), (2,1), (6,4), (5,4)], "outs": [4, 1], "fb": (6,6)},
        12: {"conns": [(2,1), (6,3), (5,3), (4,3)], "outs": [3, 1], "fb": (2,2)},
        13: {"conns": [(2,1), (6,3), (5,3), (4,3)], "outs": [3, 1], "fb": (6,6)},
        14: {"conns": [(6,4), (4,3), (5,4), (2,1)], "outs": [1, 3], "fb": (6,6)},
        15: {"conns": [(6,4), (4,3), (5,4), (2,1)], "outs": [1, 3], "fb": (2,2)},
        16: {"conns": [(6,5), (5,1), (4,3), (3,1), (2,1)], "outs": [1], "fb": (6,6)},
        17: {"conns": [(6,5), (5,1), (4,3), (3,1), (2,1)], "outs": [1], "fb": (2,2)},
        18: {"conns": [(6,5), (5,4), (4,1), (3,1), (2,1)], "outs": [1], "fb": (3,3)},
        19: {"conns": [(6,5), (6,4), (3,2), (2,1)], "outs": [1, 4, 5], "fb": (6,6)},
        20: {"conns": [(6,4), (5,4), (3,2), (3,1)], "outs": [1, 2, 4], "fb": (3,3)},
        21: {"conns": [(6,5), (6,4), (3,2), (3,1)], "outs": [1, 2, 4, 5], "fb": (3,3)},
        22: {"conns": [(6,5), (6,4), (6,3), (2,1)], "outs": [1, 3, 4, 5], "fb": (6,6)},
        23: {"conns": [(6,5), (6,4), (3,2)], "outs": [1, 2, 4, 5], "fb": (6,6)},
        24: {"conns": [(6,5), (6,4), (6,3)], "outs": [1, 2, 3, 4, 5], "fb": (6,6)},
        25: {"conns": [(6,5), (6,4)], "outs": [1, 2, 3, 4, 5], "fb": (6,6)},
        26: {"conns": [(6,4), (5,4), (3,2)], "outs": [1, 2, 4], "fb": (6,6)},
        27: {"conns": [(6,4), (5,4), (3,2)], "outs": [1, 2, 4], "fb": (3,3)},
        28: {"conns": [(5,4), (4,3), (2,1)], "outs": [1, 3, 6], "fb": (5,5)},
        29: {"conns": [(6,5), (4,3)], "outs": [1, 2, 3, 5], "fb": (6,6)},
        30: {"conns": [(5,4), (4,3)], "outs": [1, 2, 3, 6], "fb": (5,5)},
        31: {"conns": [(6,5)], "outs": [1, 2, 3, 4, 5], "fb": (6,6)},
        32: {"conns": [], "outs": [1, 2, 3, 4, 5, 6], "fb": (6,6)} 
        # 32 is just 6 distinct parallel ops.
    }

    spec = algos[algo_index]
    
    # --- Construct Matrix ---
    # 6x6 grid. SC Logic: Row = Out (Destination), Col = In (Source).
    # Indexed 0-5.
    
    # Initialize 6x6 matrix with zeros
    matrix = [[0.0 for _ in range(6)] for _ in range(6)]
    
    # 1. Apply Standard Connections
    for src, dst in spec["conns"]:
        # Convert 1-based Op ID to 0-based Index
        # Op 1 (bottom) -> Index 0
        # Op 6 (top) -> Index 5
        r = dst - 1
        c = src - 1
        matrix[r][c] = out_level[c]  # Standard modulation amount

    # 2. Apply Feedback
    # Feedback connects the operator to itself
    
    # This maps the integer 0-7 knob to the exponential 0.0 -> 4.0 gain
    feedback_val = pow(2, feedback_index - 5) if feedback_index > 0 else 0
    
    fb_src, fb_dst = spec["fb"]
    fb_src -= 1
    fb_dst -= 1
    matrix[fb_dst][fb_src] = float(feedback_val)

    # 3. Flatten Matrix for SuperCollider
    # SC expects a single array of 36 elements
    flat_matrix = []
    for row in matrix:
        flat_matrix.extend(row)

    # --- Construct Output Mixer ---
    out_mixer = [0.0] * 6
    for out_op in spec["outs"]:
        out_mixer[out_op - 1] = 1.0
        
    # Special fix for Algo 32 if logic dictates (Usually all are out)
    if algo_index == 32:
        out_mixer = [1.0] * 6

    return flat_matrix, out_mixer

def map_linear(value, raw_min, raw_max, target_min, target_max):
    """Maps a raw value linearly to a target range."""
    # Avoid division by zero
    if raw_max == raw_min: return target_min
    
    normalized = (value - raw_min) / (raw_max - raw_min)
    return target_min + (normalized * (target_max - target_min))

def map_exponential(value, raw_min, raw_max, target_min, target_max):
    """Maps a raw value exponentially to a target range."""
    if value <= raw_min: return target_min
    if value >= raw_max: return target_max
    
    # y = a * b^x
    # Solve for simple exp curve passing through min and max
    try:
        # Normalized input 0.0 to 1.0
        norm_x = (value - raw_min) / (raw_max - raw_min)
        # We want to map 0->1 to log scale of target
        # Formula: min * (max/min)^norm_x
        return target_min * ((target_max / target_min) ** norm_x)
    except:
        return target_min

def get_note_name(raw_val):
    """
    DX7 Breakpoint 0-99. 
    0 = A-1 (MIDI 21), 99 = C8 (MIDI 120).
    """
    midi_note = raw_val + 21
    note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    octave = (midi_note // 12) - 2 # Yamaha standard: C3 = 60. So 0 (C-2) is 0.
    # Adjusting to match A-1 at 21:
    # 21 // 12 = 1. 1 - 2 = -1. Correct.
    name = note_names[midi_note % 12]
    return f"{name}{octave}"

def parse_operator(ops_data, op_num):
    """
    Parses 17 bytes of operator data into the Spec structure.
    """
    # Unpack raw bytes (Standard DX7 mapping)
    # Bytes:
    # 0-3: EG Rates, 4-7: EG Levels
    # 8: Break Point, 9: L Depth, 10: R Depth
    # 11: Curves (Packed), 12: Detune/RS (Packed)
    # 13: KVS/AMS (Packed), 14: Output Level
    # 15: Mode/Coarse (Packed), 16: Fine

    # Scaling & Curves (Byte 11)
    scale_byte = ops_data[11]
    # Not requested in simplified spec, but used for internal logic if needed
    
    # Detune (Byte 12) - Bits 3-6
    det_rs_byte = ops_data[12]
    detune_raw = (det_rs_byte >> 3) & 0x0F # 0-14
    # Map 0-14 (Center 7) -> -7 to +7 -> Spec -20 to +20 Cents
    detune_centered = detune_raw - 7
    detune_cents = map_linear(detune_centered, -7, 7, -20, 20)

    # Output Level (Byte 14)
    out_lvl_raw = ops_data[14]
    
    # Convert to Linear Amplitude (0.0 to 1.0)
    amp_linear = dx7_level_to_amp(out_lvl_raw)
    
    # Convert to Modulation Index (Radians) for the Matrix
    # Max DX7 mod index is approx 4*PI (~12.57)
    # This is what goes into the Wiring Matrix.
    out_lvl_radians = round(amp_linear * 4 * math.pi, 4)

    # Envelopes (Rates & Levels)
    envelope = []
    
    # The DX7 Envelope has 4 segments.
    # Bytes 0-3 = Rates (R1, R2, R3, R4)
    # Bytes 4-7 = Levels (L1, L2, L3, L4)
    for i in range(4):
        rate_raw = ops_data[i]
        level_raw = ops_data[4+i]
        
        envelope.append({
            "stage": i + 1,
            # Rate -> Seconds
            "rate": round(dx7_rate_to_duration(rate_raw), 4),
            # Level -> 0.0 to 1.0 (Relative to Output Level)
            "level": round(dx7_level_to_amp(level_raw), 4)
        })
    
    # Frequency (Bytes 15 & 16)
    mode_byte = ops_data[15]
    mode_fixed = bool(mode_byte & 1)
    coarse = (mode_byte >> 1) & 0x1F
    fine = ops_data[16]
    
    ratio_val = None
    fixed_val = None

    if not mode_fixed:
        # Ratio Mode Calculation
        # Coarse 0=0.5, 1=1, 2=2...
        base = 0.5 if coarse == 0 else float(coarse)
        # Fine adds linear interpolation to next integer
        # Standard approximation: Base + (Base * Fine * 0.01) ? 
        # Actually Dexed: ratio = (coarse == 0) ? 0.5f : coarse; ratio *= (1 + fine / 100.0f);
        ratio_calc = base * (1.0 + (fine / 100.0))
        ratio_val = round(ratio_calc, 4)
    else:
        # Fixed Mode Calculation
        # Hz = 10^Coarse * (1 + Fine/10)
        # Coarse 0-3 used, others clamped
        c_val = coarse % 4 
        hz_calc = (10 ** c_val) * (1.0 + (fine / 10.0))
        fixed_val = round(hz_calc, 2)

    # Break Point (Byte 8)
    bp_raw = ops_data[8]
    bp_note = get_note_name(bp_raw)

    # Scale Depth (Byte 9 & 10 usually Left/Right)
    # Spec asks for "Scale Depth" 0-16dB. 
    # DX7 has separate L and R depths. We'll take the MAX of both to represent "Depth"
    # or just average. Let's take the max as the effective depth.
    l_depth = ops_data[9]
    r_depth = ops_data[10]
    max_depth_raw = max(l_depth, r_depth)
    scale_depth_db = round(map_linear(max_depth_raw, 0, 99, 0.0, 16.0), 2)

    return {
        "id": op_num,
        "output_level": out_lvl_radians,
        "frequency_ratio_mode": ratio_val,
        "frequency_fixed_mode": fixed_val,
        "detune": round(detune_cents, 1),
        "break_point": bp_note,
        "scale_depth": scale_depth_db,
        "envelope": envelope
    }

def parse_voice_to_spec(voice_data, slot_number):
    if len(voice_data) != 128: return None

    # --- 1. Parse Global Parameters (Hold off on Matrix generation) ---
    
    # Voice Name (Bytes 118-127)
    try:
        name = voice_data[118:128].decode('ascii', errors='ignore').strip()
        if not name:
            return None # Skip unnamed patches (early exit)
    except:
        return None
    
    # Algorithm (Byte 110)
    algoID = voice_data[110] + 1 # 1-32

    # Feedback (Byte 111 bits 0-2)
    fb = voice_data[111] & 0x07 # 0-7

    # LFO (Bytes 112-115)
    lfo_speed_raw = voice_data[112]
    lfo_delay_raw = voice_data[113]
    lfo_pm_raw = voice_data[114]
    lfo_am_raw = voice_data[115]

    # Map LFO Real Units
    lfo_speed_hz = map_exponential(lfo_speed_raw, 0, 99, 0.06, 50.0)
    lfo_delay_sec = map_linear(lfo_delay_raw, 0, 99, 0.0, 3.0)
    lfo_am_db = map_linear(lfo_am_raw, 0, 99, 0.0, 42.0)

    # Transpose (Byte 117)
    trans_raw = voice_data[117]
    transpose = trans_raw - 24

    # Pitch EG Levels (Bytes 106-109)
    peg_levels_raw = [voice_data[106], voice_data[107], voice_data[108], voice_data[109]]
    peg_levels_semitones = [round(map_linear(x, 0, 99, -48, 48), 1) for x in peg_levels_raw]

    # --- 2. Parse Operators ---
    operators = []
    # Op 6 is at offset 0, Op 1 at offset 85
    # The loop runs 6, 5, 4, 3, 2, 1
    for op_num in range(6, 0, -1):
        offset = (6 - op_num) * 17
        op_chunk = voice_data[offset : offset + 17]
        # parse_operator calculates 'output_level' (real units) and puts it in the dict
        operators.append(parse_operator(op_chunk, op_num))

    # --- 3. Collect Output Levels for Matrix ---
    # The 'operators' list is currently order [Op6, Op5, ... Op1].
    # get_dx7_algorithm expects a list indexable by (OpID - 1), i.e., [Op1, Op2 ... Op6]
    
    # Sort by ID to ensure correct order (1 to 6)
    sorted_ops = sorted(operators, key=lambda x: x['id'])
    
    # Extract the pre-calculated real levels
    op_levels_ordered = [op['output_level'] for op in sorted_ops]

    # --- 4. Generate Matrix ---
    # NOW we have everything needed to call the function
    algo_matrix, mixer = get_dx7_algorithm(algoID, fb, op_levels_ordered)

    # --- 5. Construct Final Object ---
    return {
        "identity": {
            "name": name,
            "slot": slot_number + 1
        },
        "global": {
            "algorithm_matrix": algo_matrix,
            "output_mixer": mixer,
            "transpose": transpose,
            "lfo_speed": round(lfo_speed_hz, 3),
            "lfo_delay": round(lfo_delay_sec, 2),
            "pitch_mod_depth": lfo_pm_raw, 
            "amp_mod_depth": round(lfo_am_db, 1),
            "pitch_eg_levels": peg_levels_semitones
        },
        "operators": operators
    }

def process_syx(input_file, output_file):
    try:
        with open(input_file, 'rb') as f:
            data = f.read()

        # Header stripping logic
        payload = None
        if len(data) == 4104:
            payload = data[6:4102]
        elif len(data) == 4096:
            payload = data
        else:
            # Helper for raw single voices or other formats
            idx = data.find(b'\xF0\x43\x00\x09\x20\x00')
            if idx != -1:
                payload = data[idx+6 : idx+6+4096]
            elif len(data) >= 4096:
                payload = data[:4096]

        if not payload:
            raise ValueError("Valid DX7 data not found.")

        bank_output = []
        num_patches = len(payload) // 128
        
        for i in range(num_patches):
            chunk = payload[i*128 : (i+1)*128]
            parsed = parse_voice_to_spec(chunk, i)
            if parsed is not None:
                bank_output.append(parsed)

        final_json = {
            "meta": {
                "source_file": input_file,
                "patch_count": len(bank_output),
                "spec_version": "1.0"
            },
            "patches": bank_output
        }

        # Generate JSON string
        json_output = json.dumps(final_json, indent=2)

        # --- Custom Formatting for 6x6 Matrix ---
        def format_matrix_grid(match):
            # Extract the inner content of the list (numbers and newlines)
            content = match.group(1)
            # Clean up and split into individual values
            values = [x.strip() for x in content.split(',') if x.strip()]
            
            # Safety check: only format if we have exactly 36 elements
            if len(values) != 36:
                return match.group(0)
            
            # Create 6 rows of 6 values
            rows = []
            for i in range(6):
                row_slice = values[i*6 : (i+1)*6]
                rows.append(", ".join(row_slice))
            
            # Reconstruct the block with proper indentation
            # Assuming standard indent=2 depth for "algorithm_matrix"
            # We align the rows for readability
            joined_rows = ",\n            ".join(rows)
            return f'"algorithm_matrix": [\n            {joined_rows}\n          ]'

        # Regex to find "algorithm_matrix": [ ... ] blocks
        # Matches the key and the bracketed content non-greedily
        json_output = re.sub(r'"algorithm_matrix": \[([\s\S]*?)\]', format_matrix_grid, json_output)

        with open(output_file, 'w') as f:
            f.write(json_output)
        
        print(f"Success: Exported {len(bank_output)} patches to {output_file}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_syx_real_units.py <input.syx> [output.json]")
    else:
        i_file = sys.argv[1]
        o_file = sys.argv[2] if len(sys.argv) > 2 else "converted_patches.json"
        process_syx(i_file, o_file)