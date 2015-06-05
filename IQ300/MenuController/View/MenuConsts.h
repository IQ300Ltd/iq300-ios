//
//  MenuConsts.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#ifndef IQ300_MenuConsts_h
#define IQ300_MenuConsts_h

#ifdef IPAD
#define MENU_BACKGROUND_COLOR [UIColor colorWithHexInt:0x1e272e]
#define MENU_SEPARATOR_COLOR [UIColor colorWithHexInt:0x1e272e]
#define MENU_CELL_SEPARATOR_COLOR [UIColor colorWithHexInt:0x1e272e]
#define MENU_CELL_BACKGROUND_COLOR [UIColor colorWithHexInt:0x26313a]
#define MENU_CELL_SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x31404c]
#define MENU_WIDTH 224.0f
#define MENU_ITEM_HEIGHT 44.5f
#else
#define MENU_BACKGROUND_COLOR [UIColor colorWithHexInt:0x1d2124]
#define MENU_SEPARATOR_COLOR [UIColor colorWithHexInt:0x161718]
#define MENU_CELL_SEPARATOR_COLOR [UIColor colorWithHexInt:0x141515]
#define MENU_CELL_BACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]
#define MENU_CELL_SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x383e43]
#define MENU_WIDTH 274.0f
#define MENU_ITEM_HEIGHT 41.0f
#endif

#endif
 