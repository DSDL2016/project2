// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// Generated by Quartus II Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
// Created on Sun May 22 00:06:14 2016

// synthesis message_off 10175

`timescale 1ns/1ns

module key_logic_fsm (
    clock,reset,k[3:0],lcd_busy,reg_busy,
    run_timer,reset_timer,insert_value,clear_value);

    input clock;
    input reset;
    input [3:0] k;
    input lcd_busy;
    input reg_busy;
    tri0 reset;
    tri0 [3:0] k;
    tri0 lcd_busy;
    tri0 reg_busy;
    output run_timer;
    output reset_timer;
    output insert_value;
    output clear_value;
    reg run_timer;
    reg reset_timer;
    reg insert_value;
    reg clear_value;
    reg [10:0] fstate;
    reg [10:0] reg_fstate;
    parameter s_pre_start=0,s_run=1,s_pre_pause=2,s_pause=3,s_idle=4,s_pre_reset=5,s_reset=6,s_retrieve=7,s_save=8,s_pre_clear=9,s_clear=10;

    always @(posedge clock)
    begin
        if (clock) begin
            fstate <= reg_fstate;
        end
    end

    always @(fstate or reset or k or lcd_busy or reg_busy)
    begin
        if (reset) begin
            reg_fstate <= s_idle;
            run_timer <= 1'b0;
            reset_timer <= 1'b0;
            insert_value <= 1'b0;
            clear_value <= 1'b0;
        end
        else begin
            run_timer <= 1'b0;
            reset_timer <= 1'b0;
            insert_value <= 1'b0;
            clear_value <= 1'b0;
            case (fstate)
                s_pre_start: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_run;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_pre_start;

                    run_timer <= 1'b1;
                end
                s_run: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_run;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_pause;
                    else if ((k[3:0] == 4'b0100))
                        reg_fstate <= s_retrieve;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_run;

                    run_timer <= 1'b1;
                end
                s_pre_pause: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_pause;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_pause;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_pre_pause;
                end
                s_pause: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_pause;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0001))
                        reg_fstate <= s_pre_clear;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_pause;
                end
                s_idle: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_idle;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0001))
                        reg_fstate <= s_pre_clear;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_idle;
                end
                s_pre_reset: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_reset;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_pre_reset;
                end
                s_reset: begin
                    if (reg_busy)
                        reg_fstate <= s_reset;
                    else if (~(reg_busy))
                        reg_fstate <= s_idle;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_reset;

                    reset_timer <= 1'b1;
                end
                s_retrieve: begin
                    reg_fstate <= s_save;

                    insert_value <= 1'b1;
                end
                s_save: begin
                    if ((lcd_busy | (k[3:0] != 4'b0000)))
                        reg_fstate <= s_save;
                    else if ((~(lcd_busy) & (k[3:0] == 4'b0000)))
                        reg_fstate <= s_run;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_save;

                    run_timer <= 1'b1;
                end
                s_pre_clear: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_clear;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_clear;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_pre_clear;
                end
                s_clear: begin
                    if (lcd_busy)
                        reg_fstate <= s_clear;
                    else if (~(lcd_busy))
                        reg_fstate <= s_pause;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= s_clear;

                    clear_value <= 1'b1;
                end
                default: begin
                    run_timer <= 1'bx;
                    reset_timer <= 1'bx;
                    insert_value <= 1'bx;
                    clear_value <= 1'bx;
                    $display ("Reach undefined state");
                end
            endcase
        end
    end
endmodule // key_logic_fsm
