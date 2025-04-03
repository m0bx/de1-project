# VHDL project
### Team members

* Andrej (Ministerstvo FPGA)
* Daniel (Ministerstvo ochrany pred slabými prúdmi)

### Abstract

This project is a multifunction digital timekeeping device that integrates clock, alarm, and stopwatch functionalities into a single, relatively friendly interface. The operational mode is determined by a combination of primary switches, SW[0] and SW[1], where each configuration selectively activates a feature: a clock that counts upward, an alarm that counts down, or a stopwatch with precise 0.0001-second intervals. Additionally, secondary switches allow for fine adjustments, enabling users to add or subtract seconds and minutes as needed, thus ensuring that both the clock and alarm can be accurately set. The alarm function is designed to trigger a buzzer and illuminate an LED indicator upon reaching zero, providing immediate feedback to the user, while the stopwatch can be reset at any time to its default state of 0000.0000. The system also incorporates several dedicated buttons that facilitate pausing, resuming, and modifying the counters, ensuring comprehensive control over the displayed time values. Overall, this design combines precision, flexibility, and intuitive user interaction, making it ideal for a wide range of applications that require robust time management capabilities.



[Photo(s) of your application with labels of individual parts.]

[Link to A3 project poster.]

[Optional: Link to your short video presentation.]

## System Functionality Overview

### SW[0] and SW[1] Control

- **Both SW[0] and SW[1] = '0':**  
  - Clock is displayed and can be set.
- **SW[0] = '0' and SW[1] = '1':**  
  - Alarm is displayed and can be set.
- **SW[0] = '1' and SW[1] = '0':**  
  - Stopwatch is displayed.
- **Both SW[0] and SW[1] = '1':**  
  - Nothing is displayed.

### Alarm Behavior

- Counts down.
- Stops when it is being set.

### Clock Behavior

- Counts up.
- Stops when it is being set.

### SW[14] and SW[15] Controls

- **SW[14] = 1:**  
  - When the clock or alarm is displayed, it can add/remove seconds to/from the counter.
- **SW[15] = 1:**  
  - When the clock or alarm is displayed, it can add/remove minutes to/from the counter.
- **Both SW[14] and SW[15] = 1:**  
  - Nothing happens; the displayed counter continues to count.

### CLK100MHZ Setup

- Would be configured to 1 million periods.
- **Stopwatch:**  
  - Functions on 0.01-second periods.
- **Digiclock and Alarm:**  
  - Function on 1-second periods.

### Button Controls

- **BTNC:**  
  - Stops/resumes the clock, alarm, or stopwatch.
- **BTNL:**  
  - Removes seconds/minutes from the counter (for alarm or clock).
- **BTNR:**  
  - Adds seconds/minutes to the counter (for alarm or clock).
- **BTND:**  
  - Resets the stopwatch:
    - Sets the stopwatch to `0`.
    - Pauses/stops the counter.
    - Displays `0000.0000`.

### Display Details

- **DP Variable:**  
  - Used as a decimal point.
- **Stopwatch Display:**  
  - Uses all 8 7-segment displays.
  - Decimal point is at AN[4] (fifth segment).
- **Clock and Alarm Display:**  
  - Use a decimal point on AN[2] (third segment).
  - Use only the first 4 AN segments.

### Buzzer (Red LED) Behavior

- Activates when the alarm countdown reaches `0`.
- Turns the variable `LED17_R` to `1`.
- Remains active until the alarm value changes from `0`.
- Possibly could blink?


## Software description


### Component(s) simulations

Write descriptive text and put simulation screenshots of components you created during the project.

## References

1. [Online testbench Generator by Bertrand Gros.](https://vhdl.lapinoo.net/)
