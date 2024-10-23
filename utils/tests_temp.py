inicial = 5

for bit in range(0, 8):
    print(f"[{bit}] {inicial}")
    inicial /= 2

temp = 0b101001

print(f"Temperature = {temp / 0b11}")

final_temperature = 0
while temp > 0:
    temp -= 0x03
    final_temperature += 1

print(f"Final temperature: {final_temperature}")