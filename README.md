# Elegí dónde

Una guía estática para explorar universidades e institutos universitarios de Argentina por nombre, sigla, área de estudio y provincia.

## Abrir la página

Abrí `index.html` en un navegador. La página no necesita instalar dependencias ni conectarse a un servicio externo.

## Actualizar el catálogo

El sitio usa `data/universidades.js` y `data/universidades-meta.js`. Los CSV y el ZIP originales del Anuario se excluyen del repositorio porque no hacen falta para publicar el sitio.

Para regenerar el catálogo localmente, primero necesitás colocar los archivos fuente del Anuario y los listados institucionales en `data/`. Luego ejecutá desde PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-data.ps1
```

El catálogo combina los listados de instituciones con las tablas del Anuario Estadístico Universitario 2022. Las categorías y etiquetas de estudio se basan en disciplinas con matrícula registrada: las fuentes no incluyen un listado de carreras individuales ni confirman la oferta vigente. Todas las fichas incluyen un resumen y un dato de interés con fuente; cuando no se encontró una curiosidad institucional verificable, se muestra una disciplina con matrícula registrada en el Anuario 2022.
