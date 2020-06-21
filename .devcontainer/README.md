# Docker image for tdiary-contrib development

Your editor is vscode? See bottom of this document.

## how to build an image

```
% docker build -t tdiary-contrib-devel .devcontainer
```

## how to run in the Docker

```
% docker run -v $(pwd):/workspace -p 9292:9292 -it --rm tdiary-contrib-devel
```

## develoment on vscode remote-container

1. Open the folder of this repository by Remte-Container Extention, then starting build a image automatically.
2. Only at first, run `.devcontainer/setup-app.sh` for making `tdiary.conf` and `.htpasswd`.
3. Open Debug (`Ctrl + Shift + D`) and start "Debug tDiary-contrib".
4. Open [`http://localhost:9292`](http://localhost:9292) in your browser.