import re

# Read log text from the file
log_file_path = '/tmp/logs'

with open(log_file_path, 'r') as file:
    log_text = file.read()

# Function to extract counterexamples from the logs
def parse_counterexamples(log_text):
    counterexamples = []
    current_example = None
    current_array = None
    
    for line in log_text.split("\n"):
        # Find counterexample start
        if "Counterexample" in line:
            if current_example:
                counterexamples.append(current_example)
            current_example = {
                'p_calls_bytes': [],
                'p_staticcalls_bytes': [],
            }
        
        # Extract p_calls or p_staticcalls arrays
        p_calls_bytes_match = re.search(r'p_calls\[\d+\]_bytes_00 = (0x[a-fA-F0-9]+)', line)
        p_staticcalls_bytes_match = re.search(r'p_staticcalls\[\d+\]_bytes_00 = (0x[a-fA-F0-9]+)', line)
        
        if p_calls_bytes_match and current_example:
            current_example['p_calls_bytes'].append(p_calls_bytes_match.group(1))
        elif p_staticcalls_bytes_match and current_example:
            current_example['p_staticcalls_bytes'].append(p_staticcalls_bytes_match.group(1))
    
    if current_example:
        counterexamples.append(current_example)
    
    return counterexamples

# Function to convert counterexamples into Solidity test cases
def generate_solidity_tests(counterexamples):
    solidity_tests = ""
    
    for idx, example in enumerate(counterexamples):
        test_name = f"test_Counterexample_{idx + 1:03d}"
        solidity_tests += f"function {test_name}() public {{\n"
        
        # Generate p_calls array
        calls_length = len(example['p_calls_bytes'])
        solidity_tests += f"    bytes[] memory calls = new bytes[]({calls_length});\n"
        for i, call in enumerate(example['p_calls_bytes']):
            solidity_tests += f"    calls[{i}] = hex\"{call[2:]}\";\n"
        
        # Generate p_staticcalls array
        staticcalls_length = len(example['p_staticcalls_bytes'])
        solidity_tests += f"    bytes[] memory staticcalls = new bytes[]({staticcalls_length});\n"
        for i, staticcall in enumerate(example['p_staticcalls_bytes']):
            solidity_tests += f"    staticcalls[{i}] = hex\"{staticcall[2:]}\";\n"
        
        solidity_tests += "}\n\n"
    
    return solidity_tests

# Parse logs and generate Solidity test cases
counterexamples = parse_counterexamples(log_text)
solidity_tests = generate_solidity_tests(counterexamples)

# Output the generated Solidity code
with open('GeneratedTest.sol', 'w') as f:
    f.write(solidity_tests)

print("Solidity test cases generated and saved to GeneratedTest.sol")
