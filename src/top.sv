`include "src/decoder.sv"

module top #(
    parameter DIVISOR = 1_500_000
)(
    input logic clk,
    input logic bt1,
    input logic bt2,
    input logic dip,
    output logic led_r,
    output logic led_b,
    output logic [7:0] seg7
);

logic slow_clk = 0;
logic [23:0] counter = 0;

always @(posedge clk) begin
    if (counter >= DIVISOR - 1) begin
        counter <= 0;
        slow_clk <= ~slow_clk;
    end else begin
        counter <= counter + 1;
    end
end

typedef enum logic [1:0] {IDLE, PRESSED, RELEASE} btn_state_t;

btn_state_t bt1_state = IDLE;
btn_state_t bt2_state = IDLE;

logic [3:0] duty_cycle1 = 0;
logic [3:0] duty_cycle2 = 0;

always @(posedge slow_clk) begin
    case (bt1_state)
    IDLE: begin
    if (bt1 == 0)
    bt1_state <= PRESSED;
    end
    PRESSED: begin
    if (bt1 == 1) begin
    bt1_state <= RELEASE;
    if (duty_cycle1 >= 9)
    duty_cycle1 <= 0;
    else
    duty_cycle1 <= duty_cycle1 + 1;
    end
    end
    RELEASE: begin
    bt1_state <= IDLE;
    end
    default: bt1_state <= IDLE;
    endcase
end


always @(posedge slow_clk) begin
    case (bt2_state)
    IDLE: begin
    if (bt2 == 0)
    bt2_state <= PRESSED;
    end
    PRESSED: begin
    if (bt2 == 1) begin
    bt2_state <= RELEASE;
    if (duty_cycle2 >= 9)
    duty_cycle2 <= 0;
    else
    duty_cycle2 <= duty_cycle2 + 1;
    end
    end
    RELEASE: begin
    bt2_state <= IDLE;
    end
    default: bt2_state <= IDLE;
    endcase
end


logic[6:0] seg7_seg;
decoder decoder_inst (
    .bcd(dip ? duty_cycle1 : duty_cycle2),
    .seg7(seg7_seg)
);

assign seg7[6:0] = seg7_seg;
assign seg7[7] = ~dip;


logic [3:0] pwm_counter1 = 0;
logic [3:0] pwm_counter2 = 0;

typedef enum logic {PWM_COUNT, PWM_RESET} pwm_state_t;

pwm_state_t pwm1_state = PWM_COUNT;
pwm_state_t pwm2_state = PWM_COUNT;

always @(posedge clk) begin
    case (pwm1_state)
    PWM_COUNT: begin
    if (pwm_counter1 >= 9) begin
    pwm_counter1 <= 0;
    pwm1_state   <= PWM_RESET;
    end else begin
    pwm_counter1 <= pwm_counter1 + 1;
    end
    end
    PWM_RESET: begin
    pwm1_state <= PWM_COUNT;
    end
    default: pwm1_state <= PWM_COUNT;
    endcase
end

always @(posedge clk) begin
    case (pwm2_state)
    PWM_COUNT: begin
    if (pwm_counter2 >= 9) begin
    pwm_counter2 <= 0;
    pwm2_state   <= PWM_RESET;
    end else begin
    pwm_counter2 <= pwm_counter2 + 1;
    end
    end
    PWM_RESET: begin
    pwm2_state <= PWM_COUNT;
    end
    default: pwm2_state <= PWM_COUNT;
    endcase
end


assign led_r = ~(pwm_counter1 < duty_cycle1);
assign led_b = ~(pwm_counter2 < duty_cycle2);

endmodule
