
# overlay: h4emp3

Gentoo overlay containing some ebuilds with more current versions than upstream,
some packages which might not be in portage at all and some ebuilds for my own
stuff.

The easiest way to use this overlay is with [layman].

```bash
wget -O /etc/layman/overlays/h4emp3.xml https://gist.githubusercontent.com/h4emp3/86f5640f3e007dbe54bfa2cc43e383b9/raw/e38c40ac7991a6115fca3886d6ee9e4fb8658003/gentoo-overlay-h4emp3.xml
layman -a h4emp3
```

[layman]: http://wiki.gentoo.org/wiki/Layman
