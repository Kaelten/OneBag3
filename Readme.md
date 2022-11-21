**OneBag3** is part of a long line of bag replacements for the default game bags that will combine all of your bags into one frame.

OneBag has a long history of minimalism and OneBag3 will continue to uphold the standard of easy of use and simplicity it's predecessors set.  Like the earlier versions, OneBag3 will continue to offer powerful options for those who wish to delve a little deeper.

Also in the vein of earlier iterations I've kept to the philosophy of doing as little work as possible, as a result the code base is very small, and most of it is in the OneCore library.  As of the time of writing there are only 268 lines of code unique to OneBag3, and only 1804 lines of code in OneCore itself.  LoC is a horrible stat in general, but it's fun none the less, and I cheat horribly since I build off the powerful [Ace3 libraries][8].

## Features
* **Now with Search**
* Combines all of your bags into one.
* Customizable number of columns
* Inherent support for addons that interact with the default bags
* Color coded slots by item rarity or bag type
* Will automatically open and close for you when visiting the auction house, bank, mailbox, merchant or when trading with another player.
* Allows only certain bags to be displayed, either by slot or type
* Custom bag bar which will highlight it's associated slots on mouseover.  This highlighting can be locked in place by clicking.
* Customizable scale, background color, alpha, and more.
* Clean and powerful graphical configuration
* Exposes WoW's built in bag sorting

## Search Syntax

Search inside of OneBag3 is powered by the [LibItemSearch library by Jalibroc][7].  As a result it supports many advanced search options.

**Advanced Filters**:

* **Quality**: q:[quality] or quality:[quality]. Example: q:epic
* **Level**: l:[level], lvl:[level] or level:[quality].  Example lvl:30
* **Type** or **Subtype**: t:[search], type:[search] or slot:[search]. Example t:weapon
* **Name**: n:[name] or name:[name]. Example: n:lockbox
* **Sets**: s:[set] or set:[set]. Example: s:fire
* **Tooltip Info**: tt:[term], tip:[term] or tooltip:[term]. Example: tt:binds

**Search Operators**

* **Logical NOT**: "!q:epic" matches items that are NOT epic.
* **Logical OR**: "q:epic | q:rare" matches items that are either epic OR rare.
* **Logical AND**: "q:epic & t:weapon" matches items that are epic AND weapons.
* **Greater Than**: "lvl: > 30" matches items that are higher than level 30.
* **Less Than**: "lvl: < 30" matches items that are less than level 30.
* **Greater or Equal to**: "lvl: => 30" matches items that are lvl 30 or greater.
* **Lesser or Equal to**: "lvl: <= 30" matches items that are lvl 30 or less.

**Special Keywords**

* **soulbound**, **bound**, **bop** - Bind on pickup items.
* **bou** - Bind on use items.
* **boe** - Bind on equip items.
* **boa** - Bind on account items.
* **quest** - Quest bound items.

## Welcome to the Family
### [OneCore][4]
The brains and the brawn of the outfit, Core does all the heavy lifting both logic and layout wise.  This is embedded in OneBag by default, and you shouldn't need to worry about installing it unless you're running no-lib builds.

### [OneBank3][6]
OneBag's brother who always like the safety of town, Bank does pretty much the exact same job for your bank slots as OneBag does for your character's bags.


## Localization
Localization is powered by WowAce's translation system. Please use the following links
to contribute to localization.  As of writing, this table shows the most recent status  
for the OneBag3 Suite.

|       Project | deDE  | esES | esMX | frFR | itIT | koKR | ptBR | ruRU | zhCN | zhTW |
|--------------:|:-----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|  [OneCore][1] | 14 NR | 100% | 5 NR | 100% |  0%  | 100% |  0%  | 100% | 100% | 100% |
|  [OneBag3][2] | 100%  | 100% | 100% | 100% | 4 NR | 100% |  0%  | 100% | 100% | 100% |
| [OneBank3][3] | 10 NR | 85%  | 85%  | 85%  | 90%  | 100% |  5%  | 3 NR | 100% | 100% |


I want to thank all the users who've been using OneBag and OneBank for so long.

[1]: https://www.wowace.com/projects/OneCore/localization/ "OneCore Localizations"
[2]: https://www.wowace.com/projects/OneBag3/localization/ "OneBag3 Localizations"
[3]: https://www.wowace.com/projects/OneBank3/localization/ "OneBank3 Localizations"

[4]: https://github.com/Kaelten/OneCore
[5]: https://github.com/Kaelten/OneBag3
[6]: https://github.com/Kaelten/OneBank3

[7]: https://github.com/Jaliborc/LibItemSearch-1.2
[8]: http://www.wowace.com/projects/Ace3