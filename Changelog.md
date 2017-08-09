v0.1.0 => 2017/01/15 => * Pristine version.
                        * Processing M3U8 (Winamp) files.
v0.2.0 => 2017/01/16 => * Processing raw TXT files added.
                        * Now a song is looked in HQ, if not found then is looked normal, if not found then is skipped.
v0.3.0 => 2017/01/17 => * Fixed bug in M3U8Interpreter#get_song_list().   
v0.4.0 => 2017/05/10 => * Full working version. Have packaged chromedriver and the adblocker extension.
v0.5.0 => 2017/06/28 => * Songs that get mischosen due to having the same name as an album will happen less. If a playable has a duration > 20 minutes then it gets known as an album and is ignored by the system.
                        * Songs that get mischosen due to being live performances will happen less. If the name of a playable contains "live" and "live" isn't part of the artist neither the song itself, then will be ignored by the system.
                        * Now the system looks for the first 3 playables in "HQ" mode, and the first 3 playables in "normal" mode instead of 1 in each case. With this modification, more matches are expected.
v0.6.0 => 2017/07/02 => * Window name fixed, now correctly displays "Weightless Player".
                        * Fixed bug that made reproduce albums instead of songs.
                        * Fixed issue that caused chromedriver to spit debugging output into the app window, standard (and error) output has been redirected.
v0.7.0 => 2017/07/18 => * Several bugfixes.
                        * Now every time something gets written to the console, its whole content gets wiped and re-written (getting riddle of verbosity thrown by the webdriver (couldn't avoid this :/)).
                        * Webdriver version updated, probably fastest response.
                        * Adblock version updated (from 1.13.2.1785 to 1.13.3.1791).
                        * Now the app successfully doesn't get closed when finishes reproducing the whole list. Instead it leaves on the automatic playing system of YouTube.
                        * Improved evasion of live performance (prioritizing high quality and studio performances).
v0.8.0 => 2017/08/08 => * Now the app successfully holds "forever" after the list gets totally reproduced.