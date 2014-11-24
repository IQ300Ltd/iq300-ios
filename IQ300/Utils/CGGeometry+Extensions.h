//
//  CGGeometry+Extensions.h
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#ifndef IQ300_CGGeometry_Extensions_h
#define IQ300_CGGeometry_Extensions_h

CG_INLINE CGFloat CGRectRight(CGRect rect)
{
    return rect.origin.x + rect.size.width;
}

CG_INLINE CGFloat CGRectBottom(CGRect rect)
{
    return rect.origin.y + rect.size.height;
}

#endif
