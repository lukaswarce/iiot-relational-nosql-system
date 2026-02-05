# Contributing Guide / Guía de Contribución

> 🇺🇸 **English** | 🇪🇸 **Español**

Thank you for your interest in contributing to this educational IIoT project!

¡Gracias por tu interés en contribuir a este proyecto educativo de IIoT!

---

## 🌍 Bilingual Project / Proyecto Bilingüe

This project maintains documentation in **English and Spanish**. When contributing, please consider both languages.

Este proyecto mantiene documentación en **inglés y español**. Al contribuir, por favor considera ambos idiomas.

---

## 📝 How to Contribute / Cómo Contribuir

### 1. Fork and Clone / Bifurcar y Clonar

```bash
# Fork the repository on GitHub
# Bifurca el repositorio en GitHub

git clone git@github.com:YOUR_USERNAME/iiot-relational-nosql-system.git
cd iiot-relational-nosql-system

# Add upstream remote
# Agregar remoto upstream
git remote add upstream git@github.com:lukaswarce/iiot-relational-nosql-system.git
```

### 2. Create a Branch / Crear una Rama

```bash
# Create feature branch / Crear rama de característica
git checkout -b feature/your-feature-name

# Or for bug fixes / O para corrección de errores
git checkout -b fix/issue-description

# For translations / Para traducciones
git checkout -b translation/file-name
```

### 3. Make Changes / Realizar Cambios

Follow the guidelines below based on what you're contributing:

Sigue las guías a continuación según lo que estés contribuyendo:

---

## 📚 Documentation Contributions / Contribuciones de Documentación

### Editing Existing Docs / Editar Documentación Existente

1. **Find the file / Encuentra el archivo**:
   - English: `docs/en/*.md`
   - Spanish: `docs/es/*.md`

2. **Make your changes / Realiza tus cambios**

3. **Check the translation pair / Verifica el par de traducción**:
   - If you modify `docs/en/MQTT-QUICK-GUIDE.md`, check if `docs/es/MQTT-GUIA-RAPIDA.md` needs updates
   - Si modificas `docs/en/MQTT-QUICK-GUIDE.md`, verifica si `docs/es/MQTT-GUIA-RAPIDA.md` necesita actualizaciones

4. **Use the glossary / Usa el glosario**:
   - Always refer to [GLOSSARY.md](GLOSSARY.md) for terms that should NOT be translated
   - Siempre consulta [GLOSSARY.md](GLOSSARY.md) para términos que NO deben traducirse

### Translation Workflow / Flujo de Traducción

#### Option A: Update Both Languages / Opción A: Actualizar Ambos Idiomas

**Preferred / Preferido** ✅

```bash
# 1. Edit English version
# 1. Editar versión en inglés
vi docs/en/MQTT-QUICK-GUIDE.md

# 2. Edit Spanish version
# 2. Editar versión en español
vi docs/es/MQTT-GUIA-RAPIDA.md

# 3. Commit both
# 3. Hacer commit de ambos
git add docs/en/MQTT-QUICK-GUIDE.md docs/es/MQTT-GUIA-RAPIDA.md
git commit -m "docs: update MQTT guide in both languages"
```

#### Option B: Single Language (Issue Will Be Created) / Opción B: Un Solo Idioma (Se Creará Issue)

```bash
# 1. Edit one language
# 1. Editar un idioma
vi docs/en/MQTT-QUICK-GUIDE.md

# 2. Commit
# 2. Hacer commit
git add docs/en/MQTT-QUICK-GUIDE.md
git commit -m "docs: update MQTT guide (EN) - ES translation pending"

# Note: GitHub Actions will create an issue for missing translation
# Nota: GitHub Actions creará un issue para la traducción faltante
```

### Translation Guidelines / Guías de Traducción

#### ✅ DO / HACER:

- **Use [GLOSSARY.md](GLOSSARY.md)** - Check technical terms before translating
- **Translate concepts** - Explain ideas in natural language
- **Keep code unchanged** - SQL, Flux, bash commands stay the same
- **Maintain formatting** - Preserve markdown structure
- **Test examples** - Ensure code works in both versions
- **Cross-reference** - Add language selector at top of files

```markdown
> [🇺🇸 **English**] | [🇪🇸 Español](../es/filename.md)
```

#### ❌ DON'T / NO HACER:

- **Don't translate SQL keywords** - `SELECT`, `FROM`, `WHERE` stay in English
- **Don't translate Flux functions** - `from()`, `range()`, `filter()` stay as-is
- **Don't translate service names** - Docker, Node-RED, MySQL, InfluxDB, etc.
- **Don't translate commands** - `docker compose up`, `mosquitto_pub`, etc.
- **Don't translate file names** - `docker-compose.yml`, `flows.json`, etc.

#### Examples / Ejemplos:

✅ **Correct / Correcto**:
```markdown
**English**: Use the `SELECT` statement to query data from MySQL tables.

**Spanish**: Usa la sentencia `SELECT` para consultar datos de tablas MySQL.
```

❌ **Incorrect / Incorrecto**:
```markdown
**Spanish**: Usa la sentencia `SELECCIONAR` para consultar datos de tablas MySQL.
```

---

## 🐛 Bug Reports / Reportes de Errores

### Before Submitting / Antes de Enviar

1. **Search existing issues** - Check if already reported
2. **Test with latest version** - `git pull origin main && docker compose pull`
3. **Check troubleshooting** - Review README troubleshooting section

### Report Template / Plantilla de Reporte

```markdown
## Bug Description / Descripción del Error
[Clear description / Descripción clara]

## Steps to Reproduce / Pasos para Reproducir
1. 
2. 
3. 

## Expected Behavior / Comportamiento Esperado
[What should happen / Qué debería suceder]

## Actual Behavior / Comportamiento Actual
[What actually happens / Qué sucede realmente]

## Environment / Entorno
- **OS / SO**: [Windows 11 / macOS 14 / Ubuntu 22.04]
- **Docker version / Versión de Docker**: [output of `docker --version`]
- **Docker Compose version**: [output of `docker compose version`]

## Logs / Registros
```bash
docker compose logs [service_name]
```

## Screenshots / Capturas de Pantalla
[If applicable / Si aplica]
```

---

## 💡 Feature Requests / Solicitudes de Características

### Template / Plantilla

```markdown
## Feature Description / Descripción de la Característica
[Clear description / Descripción clara]

## Use Case / Caso de Uso
[Why is this needed? / ¿Por qué se necesita?]

## Proposed Solution / Solución Propuesta
[How could this work? / ¿Cómo podría funcionar?]

## Alternatives / Alternativas
[Other approaches considered / Otros enfoques considerados]

## Educational Value / Valor Educativo
[How does this enhance learning? / ¿Cómo mejora el aprendizaje?]
```

---

## 🧪 Testing / Pruebas

Before submitting, test your changes:

Antes de enviar, prueba tus cambios:

### 1. Test Docker Services / Probar Servicios Docker

```bash
# Start fresh
# Iniciar limpio
docker compose down -v
docker compose up -d

# Wait for services to initialize / Esperar inicialización
sleep 30

# Check all services running / Verificar servicios corriendo
docker compose ps

# Check logs for errors / Verificar logs por errores
docker compose logs
```

### 2. Test Documentation Links / Probar Enlaces de Documentación

```bash
# Install markdown link checker (optional)
# Instalar verificador de enlaces markdown (opcional)
npm install -g markdown-link-check

# Check links / Verificar enlaces
markdown-link-check README.md
markdown-link-check docs/en/*.md
markdown-link-check docs/es/*.md
```

### 3. Test Code Examples / Probar Ejemplos de Código

Run all SQL and Flux queries from documentation to ensure they work.

Ejecuta todas las consultas SQL y Flux de la documentación para asegurar que funcionan.

```bash
# Test MySQL examples / Probar ejemplos MySQL
docker exec -it mysql mysql -uroot -prootpassword iiot_system < test.sql

# Test InfluxDB examples / Probar ejemplos InfluxDB
# Copy Flux query and paste in InfluxDB UI
```

---

## 📤 Submitting Changes / Enviar Cambios

### 1. Commit Guidelines / Guías de Commit

Use conventional commits:

Usa commits convencionales:

```bash
# Format / Formato:
# type(scope): description

# Examples / Ejemplos:
git commit -m "docs: update MQTT guide with QoS examples"
git commit -m "fix: correct MySQL init script syntax"
git commit -m "feat: add pressure sensor simulation script"
git commit -m "translation: update Spanish version of exercises"
git commit -m "chore: update Docker Compose version"
```

**Types / Tipos**:
- `docs` - Documentation changes / Cambios de documentación
- `feat` - New features / Nuevas características
- `fix` - Bug fixes / Corrección de errores
- `translation` - Translation updates / Actualizaciones de traducción
- `chore` - Maintenance / Mantenimiento
- `test` - Testing / Pruebas
- `refactor` - Code refactoring / Refactorización

### 2. Push and Create PR / Empujar y Crear PR

```bash
# Push to your fork / Empujar a tu fork
git push origin feature/your-feature-name

# Then create Pull Request on GitHub
# Luego crear Pull Request en GitHub
```

### 3. PR Description Template / Plantilla de Descripción PR

```markdown
## Description / Descripción
[What does this PR do? / ¿Qué hace este PR?]

## Type of Change / Tipo de Cambio
- [ ] Documentation / Documentación
- [ ] Bug fix / Corrección de error
- [ ] New feature / Nueva característica
- [ ] Translation / Traducción
- [ ] Breaking change / Cambio que rompe compatibilidad

## Changes Made / Cambios Realizados
- 
- 
- 

## Translation Status / Estado de Traducción
- [ ] English version updated / Versión en inglés actualizada
- [ ] Spanish version updated / Versión en español actualizada
- [ ] Both languages in sync / Ambos idiomas sincronizados
- [ ] Translation pending (issue will be created) / Traducción pendiente (se creará issue)

## Checklist / Lista de Verificación
- [ ] Code examples tested / Ejemplos de código probados
- [ ] Documentation builds without errors / Documentación se construye sin errores
- [ ] Links checked / Enlaces verificados
- [ ] Follows [GLOSSARY.md](GLOSSARY.md) guidelines / Sigue guías de [GLOSSARY.md](GLOSSARY.md)
- [ ] Commit messages follow conventional format / Mensajes de commit siguen formato convencional

## Related Issues / Issues Relacionados
Closes #[issue_number]
```

---

## 🤖 Automated Checks / Verificaciones Automáticas

When you submit a PR, GitHub Actions will automatically:

Cuando envíes un PR, GitHub Actions automáticamente:

1. **Translation Sync Check** - Verifies translation pairs are updated / Verifica que pares de traducción estén actualizados
2. **Link Check** - Validates all markdown links work / Valida que todos los enlaces markdown funcionen
3. **Create Issues** - Creates tracking issues for pending translations / Crea issues de seguimiento para traducciones pendientes

You can proceed with the PR even if translations are pending - an issue will be automatically created.

Puedes proceder con el PR incluso si las traducciones están pendientes - se creará un issue automáticamente.

---

## 🎓 Educational Content Guidelines / Guías de Contenido Educativo

This is an **educational project**. When contributing:

Este es un **proyecto educativo**. Al contribuir:

### Content Principles / Principios de Contenido

1. **Clarity / Claridad**: Write for students new to IIoT concepts
2. **Practical / Práctico**: Include hands-on examples and exercises
3. **Progressive / Progresivo**: Build concepts from simple to complex
4. **Real-world / Real**: Use realistic industrial scenarios
5. **Accessible / Accesible**: Avoid unnecessary jargon, explain when needed

### Exercise Design / Diseño de Ejercicios

When creating new exercises:

Al crear nuevos ejercicios:

- **Clear objectives** - What should students learn?
- **Time estimates** - How long should it take?
- **Rubrics** - How will it be evaluated?
- **Solutions** - Provide answer keys (instructor branch only)
- **Difficulty levels** - Mark as beginner/intermediate/advanced

---

## 📞 Getting Help / Obtener Ayuda

Need help contributing?

¿Necesitas ayuda para contribuir?

- **GitHub Discussions**: https://github.com/lukaswarce/iiot-relational-nosql-system/discussions
- **Issues**: https://github.com/lukaswarce/iiot-relational-nosql-system/issues
- **Email**: lukaswarce@gmail.com

---

## 🙏 Thank You / Gracias

Every contribution helps make this educational resource better for students worldwide!

¡Cada contribución ayuda a hacer este recurso educativo mejor para estudiantes en todo el mundo!

---

**Last Updated / Última Actualización**: February 5, 2026  
**Maintainer / Mantenedor**: LukasWarCE
