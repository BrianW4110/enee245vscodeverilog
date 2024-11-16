module vendingMachineController(
input wire clk,
input wire clr,
input wire [6:0] user_input,
input wire [2:0] BTN,
//start at 0*
//1 nickel
//2 dime
//4 quarter
//8 drink1
//16 drink2
//32 drink3
//64 drink4
output reg [7:0] amount_change,
output reg [7:0] product_price,
output reg [3:0] LD
);
//13 states
reg [3:0] ps, next_state; //present state, next state

// Amount entered
parameter A0 = 4'b0000, A5 = 4'b0001, A10 = 4'b0010, A15 = 4'b0011, 
A20 = 4'b0100, A25 = 4'b0101, A30 = 4'b0110, A35 = 4'b0111;
// Change 
parameter C0 = 4'b1000, C5 = 4'b1001, C10 = 4'b1010, C15 = 4'b1011, 
C20 = 4'b1100;
//Coin values and product (user inputs)
parameter n = 7'b0000001, d = 7'b0000010, q = 7'b0000100, 
d1 = 7'b0001000, d2 = 7'b0010000, d3 = 7'b0100000, d4 = 7'b1000000;
//0 is no change

reg [6:0] drink;

//Always Statement 1: Next State Logic
always @(*)
    begin
        case(ps)
            A0: begin
                if (BTN == n)
                    next_state = A5;
                else if (BTN == d)
                    next_state = A10;
                else if (BTN == q)
                    next_state = A25; 
                else
                    next_state = A0;
            end
            A5: begin
                if (BTN == n)
                    next_state = A10;
                else if (BTN == d)
                    next_state = A15;
                else if (BTN == q)
                    next_state = A30; 
                else
                    next_state = A5;
            end
            A10: begin
                if (BTN == n)
                    next_state = A15;
                else if (BTN == d)
                    next_state = A20;
                else if (BTN == q)
                    next_state = A35; 
                else
                    next_state = A10;
            end
            A15: begin
                if (BTN == n)
                    next_state = A20;
                else if (BTN == d)
                    next_state = A25;
                else if (BTN == q)
                    next_state = A35;
                else if (user_input == d1)
                    next_state = C0; 
                else
                    next_state = A15;
            end
            A20: begin
                if (BTN == n)
                    next_state = A25;
                else if (BTN == d)
                    next_state = A30;
                else if (BTN == q)
                    next_state = A35;
                else if (user_input == d1)
                    next_state = C5;
                else if (user_input == d2)
                    next_state = C0;  
                else
                    next_state = A20;
            end
            A25: begin
                if (BTN == n)
                    next_state = A30;
                else if (BTN == d)
                    next_state = A35;
                else if (BTN == q)
                    next_state = A35;
                else if (user_input == d1)
                    next_state = C10;
                else if (user_input == d2)
                    next_state = C5;
                else if (user_input == d3)
                    next_state = C0;  
                else
                    next_state = A25;
            end
            A30: begin
                if (user_input == d1)
                    next_state = C15;
                else if (user_input == d2)
                    next_state = C10;
                else if (user_input == d3)
                    next_state = C5;
                else if (user_input == d3)
                    next_state = C0;
                else if (user_input == 0)
                    next_state = A30;  
                else //any coin
                    next_state = A35;
            end
            A35: begin
                if (user_input == d1)
                    next_state = C20;
                else if (user_input == d2)
                    next_state = C15;
                else if (user_input == d3)
                    next_state = C10;
                else if (user_input == d3)
                    next_state = C5;
                else //any coin and no input
                    next_state = A35;
            end
            C0:
                next_state = A0;
            C5:
                next_state = A0;
            C10:
                next_state = A0;
            C15:
                next_state = A0;
            C20:
                next_state = A0;
            default next_state <= A0;
        endcase
    end

//Always Statement 2: Static Memory
always @(posedge clk or posedge clr)
    begin
        if (clr == 1)
            ps <= A0;
        else
            ps <= next_state;
    end

//Always Statement 3: Output Logic
always @(posedge clk or posedge clr)
    begin
        if (clr == 1)
            ps <= A0;
        else    
            begin
                // product_price display
                drink = user_input - BTN;
                if (drink == d1)
                    product_price = 15;
                else if (drink == d2)
                    product_price = 20;
                else if (drink == d3)
                    product_price = 25;
                else if (drink == d4)
                    product_price = 30;
                else
                    product_price = 0;
                // amount and change display
                case(ps)
                A0: begin
                    amount_change = 0;
                    LD = 4'b0000; //resets led
                end
                A5:
                    amount_change = 5;
                A10:
                    amount_change = 10;
                A15:
                    amount_change = 15;
                A20:
                    amount_change = 20;
                A25:
                    amount_change = 25;
                A30:
                    amount_change = 30;
                A35:
                    amount_change = 35;
                C0: begin
                    if (drink == d1)
                        LD = 4'b0001;
                    else if (drink == d2)
                        LD = 4'b0010;
                    else if (drink == d3)
                        LD = 4'b0100;
                    else if (drink == d4)
                        LD = 4'b1000;
                    amount_change = 0;
                end
                C5: begin
                    if (drink == d1)
                        LD = 4'b0001;
                    else if (drink == d2)
                        LD = 4'b0010;
                    else if (drink == d3)
                        LD = 4'b0100;
                    else if (drink == d4)
                        LD = 4'b1000;
                    amount_change = 5;
                end
                C10: begin
                    if (drink == d1)
                        LD = 4'b0001;
                    else if (drink == d2)
                        LD = 4'b0010;
                    else if (drink == d3)
                        LD = 4'b0100;
                    amount_change = 10;
                end
                C15: begin
                    if (drink == d1)
                        LD = 4'b0001;
                    else if (drink == d2)
                        LD = 4'b0010;
                    amount_change = 15;
                end
                C20: begin
                    if (drink == d1)
                        LD = 4'b0001;
                    amount_change = 20;
                end
                default amount_change = 0;
                endcase
            end
    end

endmodule