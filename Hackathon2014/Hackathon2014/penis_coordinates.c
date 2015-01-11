//
//  septagon_coordinates.c
//  Hackathon2014
//
//  Created by Chris Penny & Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

int **penis_coordinates(int r)
{
    int y_max = 750;
    int x_grid = 68;
    int y_grid = 50;
    int x_init = 80;
    int fudge = 20;
    
    int **penis_coordinates = malloc(sizeof(int*) * 2);
    
    int *x_penis = malloc(sizeof(int) * 7);
    int *y_penis = malloc(sizeof(int) * 7);
    
    penis_coordinates[0] = x_penis;
    penis_coordinates[1] = y_penis;
    
    if ( r == 0 ) {
        penis_coordinates[0][0] = x_init;
        penis_coordinates[1][0] = y_max;
        penis_coordinates[0][1] = x_init + x_grid - fudge;
        penis_coordinates[1][1] = y_max - y_grid - fudge;
        penis_coordinates[0][2] = x_init + 2*x_grid;
        penis_coordinates[1][2] = y_max - 2*y_grid;
        penis_coordinates[0][3] = x_init + 3*x_grid + fudge;
        penis_coordinates[1][3] = y_max - y_grid - fudge;
        penis_coordinates[0][4] = x_init + 4*x_grid;
        penis_coordinates[1][4] = y_max;
        
        penis_coordinates[0][5] = x_init + 5*x_grid;
        penis_coordinates[1][5] = y_max;
        penis_coordinates[0][6] = x_init + 7*x_grid;
        penis_coordinates[1][6] = y_max - 2*y_grid;
    }
    
    int left_shaft_x = (x_init + 2*x_grid + x_init + 3*x_grid + 2.8*fudge) / 2;
    int right_shaft_x = (x_init + 6*x_grid - fudge + x_init + 7*x_grid - 1.5*fudge) / 2;
    
    if ( r == 1 ) {
        penis_coordinates[0][0] = x_init + 4.5*x_grid;
        penis_coordinates[1][0] = y_max - y_grid - fudge;
        penis_coordinates[0][1] = x_init + 8*x_grid + fudge;
        penis_coordinates[1][1] = y_max - y_grid - fudge;
        penis_coordinates[0][2] = x_init + 9*x_grid;
        penis_coordinates[1][2] = y_max;
        penis_coordinates[0][3] = left_shaft_x;
        penis_coordinates[1][3] = y_max - 3*y_grid;
        penis_coordinates[0][4] = left_shaft_x;
        penis_coordinates[1][4] = y_max - 4.5*y_grid;
        penis_coordinates[0][5] = left_shaft_x;
        penis_coordinates[1][5] = y_max - 6*y_grid;
        penis_coordinates[0][6] = left_shaft_x;
        penis_coordinates[1][6] = y_max - 7.5*y_grid;
    }
    
    if ( r == 2 ) {
        penis_coordinates[0][0] = left_shaft_x;
        penis_coordinates[1][0] = y_max - 9*y_grid;
        penis_coordinates[0][1] = left_shaft_x;
        penis_coordinates[1][1] = y_max - 10.5*y_grid;
        penis_coordinates[0][2] = left_shaft_x;
        penis_coordinates[1][2] = y_max - 12*y_grid;
        penis_coordinates[0][3] = (x_init + 3*x_grid + fudge + x_init + 4*x_grid) / 2 - (fudge/2);
        penis_coordinates[1][3] = y_max - 13*y_grid - (fudge/2);
        penis_coordinates[0][4] = (x_init + 4*x_grid + x_init + 5*x_grid) / 2;
        penis_coordinates[1][4] = y_max - 13*y_grid - fudge*2;
        penis_coordinates[0][5] = (x_init + 5*x_grid + x_init + 6*x_grid - fudge) / 2 + (fudge/2);
        penis_coordinates[1][5] = y_max - 13*y_grid - (fudge/2);
        penis_coordinates[0][6] = right_shaft_x;
        penis_coordinates[1][6] = y_max - 12*y_grid;
    }
    
    if ( r == 3 ) {
        penis_coordinates[0][0] = right_shaft_x;
        penis_coordinates[1][0] = y_max - 10.5*y_grid;
        penis_coordinates[0][1] = right_shaft_x;
        penis_coordinates[1][1] = y_max - 9*y_grid;
        penis_coordinates[0][2] = right_shaft_x;
        penis_coordinates[1][2] = y_max - 7.5*y_grid;
        penis_coordinates[0][3] = right_shaft_x;
        penis_coordinates[1][3] = y_max - 6*y_grid;
        penis_coordinates[0][4] = right_shaft_x;
        penis_coordinates[1][4] = y_max - 4.5*y_grid;
        penis_coordinates[0][5] = right_shaft_x;
        penis_coordinates[1][5] = y_max - 3*y_grid;
        penis_coordinates[0][6] = x_init + 6*x_grid - fudge;
        penis_coordinates[1][6] = y_max - y_grid - fudge;
    }
        return penis_coordinates;
}