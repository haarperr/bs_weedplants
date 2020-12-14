Keys = {
	['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
	['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
	['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
	['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
	['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
	['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
	['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
	['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = Config or {}

Config.Plants = {}

Config.GrowthTimer = 60 -- In Minutes

Config.StartingThirst = 85.0
Config.StartingHunger = 85.0

Config.HungerIncrease = 15.0
Config.ThirstIncrease = 12.0

Config.Degrade = {min = 3, max = 5}
Config.QualityDegrade = {min = 8, max = 12}
Config.GrowthIncrease = {min = 10, max = 20}

Config.YieldRewards = {
    {type = "banana_kush", rewardMin = 5, rewardMax = 6, item = 'weed_bananakush', label = 'Banana Kush 2G'},
    {type = "blue_dream", rewardMin = 4, rewardMax = 6, item = 'weed_bluedream', label = 'Blue Dream 2G'},
    {type = "purplehaze", rewardMin = 3, rewardMax = 5, item = 'weed_purplehaze', label = 'Purple Haze 2G'},
    {type = "og_kush", rewardMin = 2, rewardMax = 3, item = 'weed_og-kush', label = 'OGKush 2G'},
}

Config.MaxPlantCount = 12

Config.BadSeedReward = "weed_og-kush_seed" -- 125

Config.GoodSeedRewards = {
    [1] = "weed_bananakush_seed", -- 185
    [2] = "weed_bluedream_seed", -- 175
    [3] = "weed_purple-haze_seed", -- 190
}

Config.WeedStages = {
    [1] = "bkr_prop_weed_01_small_01c",
    [2] = "bkr_prop_weed_med_01a",
    [3] = "bkr_prop_weed_lrg_01a",
}

Config.SeedLocations = {
    {x = 2231.685, y = 5578.843, z = 54.066, h = 278.452},
    {x = 2227.496, y = 5579.036, z = 53.952, h = 284.76},
    {x = 2222.042, y = 5579.646, z = 53.934, h = 296.832},
    {x = 2214.249, y = 5575.106, z = 53.673, h = 162.243},
    {x = 2218.734, y = 5575.268, z = 53.717, h = 95.948},
    {x = 2223.127, y = 5574.872, z = 53.73, h = 113.047},
    {x = 2227.75, y = 5574.38, z = 53.814, h = 94.541},
    {x = 2233.955, y = 5574.232, z = 53.989, h = 159.559},
    {x = 2234.59, y = 5578.732, z = 54.117, h = 6.328},
    {x = 2234.148, y = 5576.116, z = 54.041, h = 328.206},
    {x = 2229.784, y = 5576.688, z = 53.939, h = 259.681},
    {x = 2224.872, y = 5576.866, z = 53.85, h = 270.137},
    {x = 2220.167, y = 5577.162, z = 53.844, h = 272.316},
    {x = 2216.635, y = 5577.483, z = 53.847, h = 35.148},
}