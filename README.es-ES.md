

# Browserly

Una inteligente aplicación para la barra de menús de macOS que dirige las URL al navegador correcto según reglas personalizadas.

<p align="center">
  <img src="docs/images/screenshot.png" alt="Browserly menu bar popover" width="600">
</p>

## Características

- **Binario universal** — se ejecuta nativamente en Mac con **chip Apple Silicon (M1/M2/M3)** e **Intel**
- **Modo oscuro nativo** — compatible al 100 % con los cambios de apariencia del sistema de macOS
- **Reglas de dominio** — dirige `github.com` a Chrome y `twitter.com` a Safari
- **Reglas de expresiones regulares (regex)** — coincide con cualquier parte de una URL mediante expresiones regulares
- **Reglas de aplicación origen** — dirige según la aplicación que abrió el enlace (p. ej., Slack → Chrome de trabajo)
- **Decodificación de redireccionadores de URL** — "ve a través" automáticamente de los envoltorios de enlaces de Teams, Outlook, Proofpoint y Slack
- **Notificaciones de actualizaciones** — mantente informado cuando se lance una nueva versión en GitHub
- **Perfiles de navegador** — apunta a perfiles específicos de Chrome/Edge/Brave
- **Modo incógnito** — abre las URL coincidentes en ventanas privadas
- **Aplicación de barra de menús** — reside en la barra de menús, sin icono en el Dock

## Instalación

Descarga la última versión **DMG universal** desde [GitHub Releases](../../releases), ábrela y arrastra Browserly a la carpeta Aplicaciones.

Dado que la aplicación no está notariada, macOS la bloqueará al iniciarla por primera vez. Elimina la bandera de cuarentena:

```bash
xattr -d -r com.apple.quarantine /Applications/Browserly.app
```

O [compila desde el código fuente](#building-from-source).

## Uso

1. Abre Browserly: aparecerá en tu barra de menús.
2. Haz clic en el icono de la barra de menús y presiona **Establecer como predeterminado** para registrarlo como el navegador predeterminado de tu sistema.
3. Marca la casilla **Iniciar al iniciar sesión** para que Browserly se inicie automáticamente cuando enciendas tu Mac.
4. Edita tu [configuración](#configuration) para definir las reglas de enrutamiento.
5. Ahora, todas las URL interceptadas se enrutan según tus reglas.

### Prueba sin cambiar tu navegador predeterminado

Pasa una URL directamente para probar el enrutamiento sin ningún registro en el sistema:

```bash
swift run Browserly "https://github.com"
```

La aplicación procesa la URL, abre el navegador correspondiente y permanece en la barra de menús.

## Configuración

Ubicación del archivo de configuración:

```
~/Library/Application Support/Browserly/config.json
```

### Tipos de reglas

| Tipo | Coincide con | Patrón de ejemplo |
|---|---|---|
| `domain` | Nombre de host de la URL | `github.com` |
| `regex` | URL completa | `.*[?&]debug=true.*` |
| `sourceApp` | ID del paquete de la aplicación remitente | `com.tinyspeck.slackmacgap` |

### Opciones de navegador

| Campo | Descripción |
|---|---|
| `profileDirectory` | Apunta a una carpeta de perfil específica de Chromium (p. ej., `Profile 1`) |
| `isIncognito` | Establece `true` para abrir en una ventana privada/incógnito |

<details>
<summary>Ejemplo de configuración completa</summary>

```json
{
  "defaultBrowserId": "com-apple-safari",
  "browsers": [
    {
      "id": "com-apple-safari",
      "name": "Safari",
      "bundleId": "com.apple.Safari",
      "isIncognito": false
    },
    {
      "id": "google-chrome",
      "name": "Chrome",
      "bundleId": "com.google.Chrome",
      "isIncognito": false
    },
    {
      "id": "chrome-work",
      "name": "Chrome (Work Profile)",
      "bundleId": "com.google.Chrome",
      "profileDirectory": "Profile 1",
      "isIncognito": false
    }
  ],
  "rules": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Work Domain",
      "type": "domain",
      "pattern": "github.com",
      "targetBrowserId": "chrome-work"
    },
    {
      "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "name": "Social Media (Regex)",
      "type": "regex",
      "pattern": ".*(twitter|facebook|instagram)\\.com",
      "targetBrowserId": "com-apple-safari"
    },
    {
      "id": "7da7b810-9dad-11d1-80b4-00c04fd430c9",
      "name": "Slack Links",
      "type": "sourceApp",
      "pattern": "com.tinyspeck.slackmacgap",
      "targetBrowserId": "chrome-work"
    }
  ]
}
```

</details>

## Compilación desde el código fuente

Requiere Swift 5.9+ y macOS 14 (Sonoma) o posterior.

```bash
swift build                      # compilación de depuración
swift build -c release           # compilación de lanzamiento
swift Tests/Validate.swift       # validación de enrutamiento independiente (no requiere Xcode)
swift test                       # suite de pruebas completa (requiere Xcode)
```
