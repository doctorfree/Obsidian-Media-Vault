---
banner: "assets/banners/Dataview-Banner.png"
banner_x: 1.0
banner_y: 1.0
---

# Beets Progressive Rock Albums

This code displays all albums in a progressive genre from the Beets folder with a release year sorted by genre.

````markdown
```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  genre AS "Genre",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year > 0 AND contains(genre, "Prog")
SORT genre ASC
```
````

Output of above code:

```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  genre AS "Genre",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year > 0 AND contains(genre, "Prog")
SORT genre ASC
```
