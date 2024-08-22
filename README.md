### !!! DO NOT MERGE THIS BRANCH WITH MAIN !!!

Only checkout the following files (if there are any updates):

- scenes\Player.tscn (The real Player.tscn on main exists in a different directory. See instructions below)
- scripts\player\player.gd

```
git checkout main
git checkout player_movement -- scenes/player/Player.tscn
mv scenes/Player.tscn scenes/player/Player.tscn
git checkout player_movement -- scripts/player/player.gd
git add .
```

This is another project entirely. Since I didn't have access to this Team Rocket repo, I 
just made a new Project and did the player movement state chart. When I did get access to 
this repo, I cloned the Team Rocket repo, made a new branch for player movement, and 
literally overwrote this new branch with my existing project.
