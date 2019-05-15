%% Declare and add essential paths 
clc; clear; close all;
set_up.head_dir = '../..';

set_up.prm_folder  = fullfile(set_up.head_dir, 'prm'); 
set_up.func_folder = fullfile(set_up.head_dir, 'functions');

addpath(genpath(set_up.prm_folder)); 
addpath(genpath(set_up.func_folder)); 

