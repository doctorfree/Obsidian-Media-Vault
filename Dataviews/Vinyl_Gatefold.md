---
banner: "assets/banners/Vinyl-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# Gatefold Vinyl Albums

This code displays gatefold vinyl albums from the Vinyl folder sorted by artist. The dataview queries look like the following:

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(formats, "Gatefold")
GROUP BY "**" + artist + "**"
```
````

## Gatefold Vinyl Albums

```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(formats, "Gatefold")
GROUP BY "**" + artist + "**"
```
