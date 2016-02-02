//
//  yuv2rgb.c
//  DVRLibDemo
//
//  Created by Liu Leon on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZYuv2RGB.h"

static unsigned char clp[1024];
static long int crv_tab[256];
static long int cbu_tab[256];
static long int cgu_tab[256];
static long int cgv_tab[256];
static long int tab_76309[256];  // for clip in CCIR601

@implementation EZYuv2RGB

+ (void)setupDitherTable
{
    long int crv,cbu,cgu,cgv;
    int i,ind;
    
    crv = 104597; 
    cbu = 132201; /* fra matrise i global.h */
    cgu = 25675; 
    cgv = 53279;
    
    for (i = 0; i < 256; i++) 
    {
        crv_tab[i] = (i-128) * crv;
        cbu_tab[i] = (i-128) * cbu;
        cgu_tab[i] = (i-128) * cgu;
        cgv_tab[i] = (i-128) * cgv;
        tab_76309[i] = 76309*(i-16);
    }
    
    for (i=0; i<384; i++)
    {
        clp[i] =0;
    }
    
    ind = 384;
    
    for (i=0;i<256; i++)
    {
        clp[ind++]=i;
    }
    
    ind = 640;
    
    for (i=0;i<384;i++)
    {
        clp[ind++]=255;
    }
}
   
   // Convert the YUV420p to RGBA format, note that the linewidth of U, V array is half of the Y array.
   // E.g. for CIF, src0 linewdith is 352, src1 and src2 linewidth is 176
+ (void)convertYuv420ToRgb32:(uint8_t *)src0 src1:(uint8_t *)src1 src2:(uint8_t *)src2 dst:(uint8_t *)dst width:(int)width height:(int)height
{
    long int y1,y2,u,v;
    unsigned char *py1,*py2;
    long int i,j, c1, c2, c3, c4;
    unsigned char *d1, *d2;
    
    py1 = src0;
    py2 = py1+width;
    d1 = dst;
    d2 = d1+4*width;
    
    for (j = 0; j < height; j += 2) 
    {
        for (i = 0; i < width; i += 2) 
        {
            // For some reason the red and blue color reverse when
            // display on Apple devices. As a tricky solution, we
            // switch the R and B byte in the RGB32 pixel value.
            u = *src1++;
            v = *src2++;
            c1 = crv_tab[v];
            c2 = cgu_tab[u];
            c3 = cgv_tab[v];
            c4 = cbu_tab[u];
            
            //up-left
            y1 = tab_76309[*py1++];
            *d1++ = clp[384+((y1 + c4)>>16)];
            *d1++ = clp[384+((y1 - c2 - c3)>>16)];
            *d1++ = clp[384+((y1 + c1)>>16)];
            d1++;
            
            //down-left
            y2 = tab_76309[*py2++];
            *d2++ = clp[384+((y2 + c4)>>16)];
            *d2++ = clp[384+((y2 - c2 - c3)>>16)];
            *d2++ = clp[384+((y2 + c1)>>16)];
            d2++;
            
            //up-right
            y1 = tab_76309[*py1++];
            *d1++ = clp[384+((y1 + c4)>>16)];
            *d1++ = clp[384+((y1 - c2 - c3)>>16)];
            *d1++ = clp[384+((y1 + c1)>>16)];
            d1++;
            
            //down-right
            y2 = tab_76309[*py2++];
            *d2++ = clp[384+((y2 + c4)>>16)];
            *d2++ = clp[384+((y2 - c2 - c3)>>16)];
            *d2++ = clp[384+((y2 + c1)>>16)];
            d2++;
        }
        
        d1 += 4*width;
        d2 += 4*width;
        py1+= width;
        py2+= width;
    }
}

@end


