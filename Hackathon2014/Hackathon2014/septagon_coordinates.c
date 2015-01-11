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

int **septagon_coordinates(int r, int x_center, int y_center)
{
    double theta[7] = { 0, 0.897597901025655, 1.795195802051310,
                           2.692793703076966, 3.590391604102621,
                           4.487989505128276, 5.385587406153931 };
    
    int *x = malloc(sizeof(int) * 7);
    int *y = malloc(sizeof(int) * 7);
    
    for(int i = 0; i < 7; i++)
    {
        x[i] = (int)((-1 * r) * sin(theta[i]));
        y[i] = (int)((-1 * r) * cos(theta[i]));
    }
    
    int **coordinates = malloc(sizeof(int*) * 2);
    coordinates[0] = x;
    coordinates[1] = y;
    
    for(int i = 0; i < 7; i++)
    {
        coordinates[0][i] = coordinates[0][i] + x_center;
        coordinates[1][i] = coordinates[1][i] + y_center;
    }
    
    return coordinates;
}