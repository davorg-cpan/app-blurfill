# Docker Usage

The `davorg/app-blurfill` image contains the App::BlurFill Perl API and the
`blurfill` command-line program. It intentionally contains no web framework.

```bash
docker build -f docker/Dockerfile -t davorg/app-blurfill:0.0.6 .
docker run --rm -v "$PWD:/work" davorg/app-blurfill:0.0.6 \
  blurfill /work/picture.png
```

The image is also the base for `davorg/app-blurfill-web`.
