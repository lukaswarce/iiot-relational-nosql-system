# Practical Exercises - IIoT Databases

> [🇺🇸 **English**] | [🇪🇸 Español](../es/EJERCICIOS.md)

**4 Graded Exercises with Evaluation Rubrics**

---

## 📋 Exercise Index

1. **[Exercise 1: Database Selection](#exercise-1-database-selection)** (During class - 3 min)
   - Difficulty: ⭐ Basic
   - Points: 5
   
2. **[Exercise 2: SQL and Flux Queries](#exercise-2-sql-and-flux-queries)** (Homework - 2 hours)
   - Difficulty: ⭐⭐ Intermediate
   - Points: 15

3. **[Exercise 3: Schema Design](#exercise-3-schema-design)** (Homework - 3 hours)
   - Difficulty: ⭐⭐⭐ Advanced
   - Points: 20

4. **[Exercise 4: Node-RED Implementation](#exercise-4-node-red-implementation)** (Bonus - 4 hours)
   - Difficulty: ⭐⭐⭐⭐ Expert
   - Points: 15 bonus

**Total Points**: 55 (+ 15 bonus = 70 maximum)

---

## 🎯 Exercise 1: Database Selection

**Type**: In-class (3 minutes)  
**Mode**: Individual  
**Points**: 5  
**Objective**: Apply selection criteria between SQL and NoSQL for IIoT scenarios

### Instructions

For each of the following 5 scenarios, indicate which type of database you would use:
- **M** = MySQL (Relational SQL)
- **I** = InfluxDB (Time-Series NoSQL)
- **A** = Both (Polyglot Persistence)

Write only the corresponding letter. No justification needed.

### Scenarios

| # | Scenario | Answer |
|---|----------|--------|
| 1 | Employee registration system with hierarchical departments and payroll | ___ |
| 2 | Temperature monitoring of 50 refrigerators every 5 seconds | ___ |
| 3 | Bottling plant: production batches + filling sensor data | ___ |
| 4 | Real-time dashboard of building power consumption (1 reading/sec) | ___ |
| 5 | Purchase order system with inventory, suppliers, and invoices | ___ |

### Evaluation Rubric

| Criterion | Points |
|-----------|--------|
| 5 correct answers | 5 pts |
| 4 correct answers | 4 pts |
| 3 correct answers | 3 pts |
| 2 correct answers | 2 pts |
| 0-1 correct answers | 0 pts |

### Correct Answers

<details>
<summary>👁️ View Answers</summary>

| # | Answer | Justification |
|---|--------|---------------|
| 1 | **M** | Transactional data, hierarchical relationships (dept → employees), low frequency |
| 2 | **I** | High frequency (50 sensors × 12 readings/min = 600 writes/min), temperature only |
| 3 | **A** | Polyglot: batches/quality in MySQL (transactional), sensors in InfluxDB (high freq) |
| 4 | **I** | Real-time, high frequency (1/sec), continuous monitoring |
| 5 | **M** | Complex transactions, ACID integrity, multiple relationships (FK) |

</details>

---

## 📝 Exercise 2: SQL and Flux Queries

**Type**: Homework  
**Mode**: Individual  
**Estimated Time**: 2 hours  
**Points**: 15  
**Submission**: File `ejercicio2_consultas.sql` and `ejercicio2_consultas.flux`

### Objective

Demonstrate mastery of SQL and Flux syntax by writing functional queries.

### Part A: MySQL Queries (9 points)

Write SQL queries for:

#### Query 1 (2 pts): Critical Batches

Get all batches with average `quality_score` **below 7.0**, showing:
- `batch_code`
- `product_name`
- Average quality (alias: `avg_quality`)
- Number of inspections (alias: `inspection_count`)

Order by average quality ascending.

**Required tables**: `production_batches`, `quality_inspections`

<details>
<summary>💡 Hint</summary>

You'll need JOIN and GROUP BY. Filter with HAVING for averages.

</details>

---

#### Query 2 (3 pts): Production by Line and Day

Get production summary grouped by `line_name` and day (`DATE(start_time)`):
- `line_name`
- `production_date`
- Total batches that day (alias: `daily_batches`)
- Sum of units produced (alias: `total_units`)

Include only the last 7 days. Order by date descending.

**Required tables**: `production_batches`, `production_lines`

<details>
<summary>💡 Hint</summary>

```sql
DATE(start_time) as production_date
WHERE start_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY line_name, DATE(start_time)
```

</details>

---

#### Query 3 (4 pts): Transaction with Validation

Write a transaction that:
1. Creates a new batch (values of your choice, line_id must exist)
2. Records start event (`event_type = 'start'`)
3. Records first quality inspection (quality_score between 0-10)
4. If ALL successful: COMMIT
5. Include appropriate error handling

**Requirement**: Use variables (`@batch_id`) to capture `LAST_INSERT_ID()`

<details>
<summary>💡 Hint</summary>

```sql
START TRANSACTION;
-- INSERT batch
SET @batch_id = LAST_INSERT_ID();
-- INSERT event
-- INSERT inspection
COMMIT;
```

</details>

---

### Part B: InfluxDB Flux Queries (6 points)

Write Flux queries for:

#### Query 4 (2 pts): Maximum Temperature Last 3 Hours

Get the maximum temperature recorded in the last 3 hours.

**Bucket**: `iiot_sensors`  
**Measurement**: `temperature`  
**Field**: `value`

<details>
<summary>💡 Hint</summary>

```flux
from(bucket: "iiot_sensors")
  |> range(start: -3h)
  |> filter(...)
  |> max()
```

</details>

---

#### Query 5 (2 pts): Downsampling to 10 Minutes

Get average pressure every 10 minutes for the last 2 hours.

**Expected output**: ~12 rows (2 hours / 10 min)

<details>
<summary>💡 Hint</summary>

```flux
|> aggregateWindow(every: 10m, fn: mean)
```

</details>

---

#### Query 6 (2 pts): Temperature Spike Detection

Get all moments where temperature exceeded **85°C** in the last 30 minutes.

Sort by time descending, limit to 20 results.

<details>
<summary>💡 Hint</summary>

```flux
|> filter(fn: (r) => r["_value"] > 85.0)
|> sort(columns: ["_time"], desc: true)
|> limit(n: 20)
```

</details>

---

### Evaluation Rubric - Exercise 2

| Aspect | Excellent (100%) | Good (75%) | Acceptable (50%) | Insufficient (0%) |
|--------|------------------|------------|------------------|-------------------|
| **Syntax** | No errors, executes | Minor errors | Major errors | Doesn't execute |
| **Logic** | Correct result | Partial result | Incorrect logic | Doesn't address problem |
| **Comments** | Well commented | Basic comments | No comments | - |
| **Style** | Clean code, indented | Readable | Messy | Unreadable |

**Points per Query**:
- Query 1: 2 pts
- Query 2: 3 pts
- Query 3: 4 pts
- Query 4: 2 pts
- Query 5: 2 pts
- Query 6: 2 pts

**Total Part A**: 9 pts  
**Total Part B**: 6 pts  
**Total Exercise 2**: 15 pts

### Submission

Create file `ejercicio2_LASTNAME.zip` containing:
- `consultas_mysql.sql` (queries 1-3)
- `consultas_flux.flux` (queries 4-6)
- `README.txt` with:
  - Full name
  - Date
  - Execution instructions
  - Screenshots of results (optional but recommended)

---

## 🏗️ Exercise 3: Schema Design

**Type**: Homework  
**Mode**: Individual or pairs  
**Estimated Time**: 3 hours  
**Points**: 20  
**Submission**: PDF document + SQL files

### Scenario

Design database for a **beverage bottling plant** with these requirements:

#### Functional Requirements

**R1 - Production Lines**:
- 3 lines: Sodas, Water, Juices
- Each line has maximum speed (bottles/minute)

**R2 - Products**:
- Multiple products (Coca-Cola, Sprite, Water, etc.)
- Each product: code, name, volume (ml), type

**R3 - Production Batches**:
- Record batches with: start date/time, end date/time, product, line, target quantity, actual quantity
- Status: planned, in_progress, completed, canceled

**R4 - IoT Sensors** (high-frequency data):
- Filler temperature (1 reading/second)
- Carbonation pressure (1 reading/2 seconds)
- Tank level (1 reading/5 seconds)
- Conveyor speed (1 reading/second)

**R5 - Quality Control**:
- Periodic inspections per batch
- Parameters: correct volume (ml), sealing OK, labeling OK, printed date OK
- Each inspection has result (approved/rejected) and observations

**R6 - Events**:
- Event log: batch start, batch end, emergency stop, product change, maintenance
- Each event: timestamp, type, description, user

### Tasks

#### Task 1: Entity-Relationship Model (6 pts)

Create ER diagram showing:
- ✅ Entities (rectangles)
- ✅ Key attributes (underlined)
- ✅ Relationships (diamonds) with cardinality (1:1, 1:N, N:M)
- ✅ Relationship attributes if applicable

**Suggested tools**: draw.io, Lucidchart, MySQL Workbench, paper and photo

---

#### Task 2: SQL Schema (8 pts)

Write `schema.sql` (mysql/schema.sql) with:

**2.1 Relational Tables** (5 pts):
- `production_lines` (lines)
- `products` (products)
- `production_batches` (batches)
- `quality_inspections` (inspections)
- `production_events` (events)

Requirements:
- ✅ Primary Keys
- ✅ Foreign Keys with appropriate ON DELETE/UPDATE
- ✅ CHECK constraints for validations (e.g.: actual_quantity <= target_quantity)
- ✅ Appropriate data types (INT, VARCHAR, DECIMAL, DATETIME, ENUM)
- ✅ Comments explaining design decisions

**2.2 Indexes** (1 pt):
- Index on `production_batches.fecha_inicio`
- Index on `production_events.timestamp`
- Justify why these indexes

**2.3 Views** (1 pt):
- `v_produccion_actual`: Batches in progress with line and product info
- `v_calidad_resumen`: Quality summary by product (% approved)

**2.4 Stored Procedure** (1 pt):
- `sp_registrar_lote_completo`: Create batch + start event in transaction

---

#### Task 3: Time-Series Strategy (4 pts)

Document explaining:

**3.1 InfluxDB Structure** (2 pts):
- What measurements to use?
- What tags vs fields?
- Why this structure?

**3.2 Data Retention** (1 pt):
- Propose retention policy (e.g.: raw 30 days, downsampled 1 year)
- Justify decision

**3.3 Example Flux Query** (1 pt):
- Query that detects abnormal filler temperature (>80°C or <5°C) in last hour

---

#### Task 4: Polyglot Justification (2 pts)

Document answering:

1. Why NOT use only MySQL for everything?
2. Why NOT use only InfluxDB for everything?
3. What advantages does hybrid architecture provide?
4. What disadvantages/complexities does it introduce?

**Length**: 1-2 pages (500-1000 words)

---

### Evaluation Rubric - Exercise 3

| Aspect | Excellent (100%) | Good (75%) | Acceptable (50%) | Insufficient (25%) |
|--------|------------------|------------|------------------|-------------------|
| **ER Diagram** | Complete, correct cardinalities | Almost complete, minor errors | Incomplete, major errors | Very incomplete |
| **SQL Schema** | All tables, correct PKs/FKs, constraints | Mostly correct | Several errors | Many errors |
| **Normalization** | 3NF, no redundancy | Acceptable normalization | Poor normalization | Not normalized |
| **InfluxDB Strategy** | Optimal structure justified | Acceptable | Suboptimal | Incorrect |
| **Justification** | Solid arguments, cites concepts | Basic justification | Poorly elaborated | Superficial |
| **Documentation** | Very clear, professional | Clear | Basic | Confusing |

**Point Distribution**:
- Task 1 (ER): 6 pts
- Task 2 (SQL): 8 pts
- Task 3 (TSDB): 4 pts
- Task 4 (Justification): 2 pts

**Total**: 20 pts

### Excellence Criteria (Bonus +2 pts)

- ✨ Triggers for automatic auditing
- ✨ Calculated functions (e.g.: batch efficiency %)
- ✨ Realistic sample data (INSERT statements)
- ✨ Complete architecture diagram (includes MQTT, Grafana)

### Submission

File `ejercicio3_LASTNAME.zip` containing:
1. `diagrama_er.png` (or .pdf)
2. `schema.sql`
3. `estrategia_tsdb.pdf`
4. `justificacion_polyglot.pdf`
5. `README.txt` with instructions

---

## 🚀 Exercise 4: Node-RED Implementation (BONUS)

**Type**: Bonus  
**Mode**: Individual  
**Estimated Time**: 4 hours  
**Points**: 15 bonus  
**Submission**: File `flows.json` + demo video

### Objective

Implement functional Node-RED flow demonstrating **Polyglot Persistence** in action.

### Minimum Requirements (10 pts)

#### Component 1: Sensor Simulator (3 pts)

**Implement**:
- Inject node every 2 seconds
- Function node that generates:
  - `temperature`: random 15-95°C
  - `pressure`: random 2.0-5.0 bar
  - `timestamp`: ISO 8601
  - `sensor_id`: "SENSOR_001"

**Output**: Structured JSON

---

#### Component 2: MQTT Publication (2 pts)

**Implement**:
- MQTT out node connected to `mosquitto:1883`
- Topic: `iiot/planta/sensores`
- QoS: 1
- Message: Simulator JSON

---

#### Component 3: Dual Persistence (5 pts)

**Implement**:
- MQTT in node subscribed to `iiot/planta/sensores`
- **Route 1 - InfluxDB** (2.5 pts):
  - Write temperature and pressure to InfluxDB
  - Measurement: `sensor_readings`
  - Tags: `sensor_id`
  - Fields: `temperature`, `pressure`
  
- **Route 2 - MySQL** (2.5 pts):
  - If temperature > 80°C → INSERT in table `alertas`
  - Fields: `sensor_id`, `valor`, `tipo_alerta`, `timestamp`
  - Type: "temperatura_alta"

---

### Advanced Requirements (5 additional pts)

#### Advanced 1: Pre-Storage Aggregation (2 pts)

- Calculate moving average of 5 readings before writing to InfluxDB
- Use buffer/smooth node

#### Advanced 2: Dashboard (2 pts)

- UI Dashboard with gauge showing current temperature
- Historical chart last 10 minutes

#### Advanced 3: Cross-DB Correlation (1 pt)

- Query that reads from MySQL and InfluxDB
- Show alerts (MySQL) with temporal context (InfluxDB)

---

### Evaluation Rubric - Exercise 4

| Criterion | Points |
|-----------|--------|
| Simulator works correctly | 3 pts |
| MQTT publishes messages | 2 pts |
| InfluxDB receives data | 2.5 pts |
| MySQL receives alerts | 2.5 pts |
| **Minimum Subtotal** | **10 pts** |
| Pre-storage aggregation | +2 pts |
| UI Dashboard | +2 pts |
| Cross-DB correlation | +1 pt |
| **Maximum Total** | **15 pts** |

### Additional Criteria

| Aspect | Deduction |
|--------|-----------|
| Flow doesn't import correctly | -2 pts |
| Errors in Node-RED logs | -1 pt per unhandled error |
| No comments in function nodes | -1 pt |
| Demo video absent or unclear | -2 pts |

### Submission

File `ejercicio4_LASTNAME.zip` containing:
1. `flows.json` (exported from Node-RED)
2. `video_demo.mp4` (2-3 min showing functionality)
3. `instrucciones.md` with:
   - Dependencies (additional nodes if used)
   - Import steps
   - Required configuration
4. `capturas/` (screenshots of dashboards, data in DBs)

### Demo Video Must Show

- ✅ Complete flow in Node-RED
- ✅ Inject triggering simulator
- ✅ Debug showing MQTT messages
- ✅ Data appearing in InfluxDB (UI or query)
- ✅ Alerts in MySQL (Adminer or query)
- ✅ Dashboard if implemented (optional)

---

## 📊 Scoring Summary

| Exercise | Difficulty | Points | Type |
|----------|------------|--------|------|
| Exercise 1 | ⭐ | 5 | In-class |
| Exercise 2 | ⭐⭐ | 15 | Homework |
| Exercise 3 | ⭐⭐⭐ | 20 | Homework |
| Exercise 4 | ⭐⭐⭐⭐ | 15 | Bonus |
| **Base Total** | | **40** | |
| **Total with Bonus** | | **55** | |

### Grade Conversion (Out of 10)

| Points | Grade/10 |
|--------|----------|
| 38-40+ | 10.0 |
| 36-37 | 9.5 |
| 34-35 | 9.0 |
| 32-33 | 8.5 |
| 30-31 | 8.0 |
| 28-29 | 7.5 |
| 26-27 | 7.0 |
| 24-25 | 6.5 |
| 22-23 | 6.0 |
| <22 | <6.0 |

**Note**: Exercise 4 (bonus) can raise grade above 10 according to scale.

---

## 📅 Submission Calendar

| Exercise | Assignment Date | Submission Date | Days |
|----------|----------------|-----------------|------|
| Exercise 1 | During class | End of class | 0 |
| Exercise 2 | Monday post-class | Friday +7 days | 7 |
| Exercise 3 | Monday post-class | Friday +14 days | 14 |
| Exercise 4 | Monday post-class | Friday +21 days | 21 |

---

## 🆘 Help Resources

### Documentation
- MySQL: https://dev.mysql.com/doc/
- InfluxDB: https://docs.influxdata.com/
- Node-RED: https://nodered.org/docs/
- Flux: https://docs.influxdata.com/flux/

### Examples in Project
- `QUERY-EXAMPLES.md`: Commented queries
- `mysql/init/init.sql`: Reference schema
- `nodered/flows.json`: Existing flows

### Office Hours
- **How**: lukaswarce@gmail.com

### Frequently Asked Questions

**Q: Can I use other databases?**
A: Not for these exercises. Focus is specifically on MySQL and InfluxDB.

**Q: Can Exercise 3 be done in pairs?**
A: Yes, but both must contribute equitably. Include contribution statement.

**Q: What if my Docker doesn't work?**
A: Contact immediately. You can use local installation or cloud trials.

**Q: Is Exercise 4 mandatory?**
A: No, it's bonus. You can get maximum grade without it.

**Q: Can I submit early?**
A: Yes! You'll receive early feedback.

---

## ✅ Pre-Submission Checklist

### For Exercise 2
- [ ] Queries execute without errors
- [ ] Results are correct (verify with sample data)
- [ ] Code has comments
- [ ] Correct file names
- [ ] README included

### For Exercise 3
- [ ] ER diagram complete and legible
- [ ] SQL schema imports without errors
- [ ] Constraints work (test violations)
- [ ] Documents in PDF
- [ ] Zip named correctly

### For Exercise 4
- [ ] Flow imports correctly
- [ ] All connections configured
- [ ] Demo video recorded and compressed
- [ ] Clear instructions
- [ ] Zip named correctly

---

## 🎓 Academic Honesty Criteria

### Allowed ✅
- Consult official documentation
- Use project examples as reference
- Discuss general concepts with classmates
- Ask for help in office hours
- Use Stack Overflow for specific syntax

### NOT Allowed ❌
- Copy complete code from classmates
- Share complete solutions
- Use solutions from previous years
- Hire third parties to do work
- Plagiarize documentation (paraphrasing is OK)

---

## 🌟 Success Tips

### Time Management
1. **Don't leave for last day** - Exercise 3 requires 3 real hours
2. **Start with Exercise 2** (more straightforward) to build confidence
3. **Exercise 4 optional** - Only if time and interest

### Problem-Solving Strategy
1. **Read requirements twice** before starting
2. **Test incrementally** - Don't wait to finish everything
3. **Use sample data** from project to validate
4. **Document while working** - Not at the end

### Debugging
1. **SQL errors**: Copy complete message, google it
2. **Flux errors**: Verify bucket/measurement names
3. **Node-RED**: Use debug nodes generously
4. **Stack Overflow is your friend**: Search specific error messages

### Presentation
1. **Clean code**: Indent, consistent spacing
2. **Useful comments**: Explain WHY, not WHAT
3. **Clear README**: Someone else should be able to execute
4. **Screenshots help**: Especially for Exercise 3

---

## 📧 Submission Format

### File Naming

```
ejercicio[N]_[LASTNAME]_[FIRSTNAME].zip

Examples:
ejercicio2_Garcia_Maria.zip
ejercicio3_Rodriguez_Carlos.zip
ejercicio4_Lopez_Ana.zip
```

### Internal Zip Structure

```
ejercicio2_Garcia_Maria/
├── consultas_mysql.sql
├── consultas_flux.flux
└── README.txt

ejercicio3_Rodriguez_Carlos/
├── diagrama_er.png
├── schema.sql
├── estrategia_tsdb.pdf
├── justificacion_polyglot.pdf
└── README.txt

ejercicio4_Lopez_Ana/
├── flows.json
├── video_demo.mp4
├── instrucciones.md
└── capturas/
    ├── influxdb.png
    ├── mysql.png
    └── dashboard.png
```

### Submission Email

**Subject**: `[IIoT-BD] Exercise [N] - [Lastname]`

**Body**:
```
Name: [Full Name]
Course: IIoT Databases
Exercise: [Number]
Submission Date: [DD/MM/YYYY]

Attached files:
- ejercicio[N]_[Lastname].zip ([size] MB)

Optional comments:
[Any relevant notes for grading]

Honesty Declaration:
I declare that this work is original and complies with
the course's academic honesty policies.

Signature: [Name]
```

---

## 🏆 Excellence Criteria

To obtain **outstanding grade** (>9.5/10):

### Technical
- ✨ Exceptionally clean and documented code
- ✨ Optimized solutions (appropriate indexes, efficient queries)
- ✨ Robust error handling
- ✨ Implementation goes beyond minimum requirements

### Conceptual
- ✨ Justifications demonstrate deep understanding
- ✨ Scalability and maintainability considerations
- ✨ Creative application of concepts to new scenarios

### Presentation
- ✨ Professional documentation (diagrams, formatting)
- ✨ Exhaustive but concise README
- ✨ Well-edited and narrated demo video (Exercise 4)

---

## 📈 Self-Evaluation

Before submitting, answer:

| Question | Yes | No |
|----------|-----|----|
| Do all queries execute without errors? | ☐ | ☐ |
| Are the results correct? | ☐ | ☐ |
| Is the code commented? | ☐ | ☐ |
| Did I test with sample data? | ☐ | ☐ |
| Is the documentation clear? | ☐ | ☐ |
| Does it meet minimum requirements? | ☐ | ☐ |
| Are files named correctly? | ☐ | ☐ |
| Is ZIP < 50 MB? | ☐ | ☐ |

If all answers are **Yes** → Ready to submit! 🎉

---

**Good luck with the exercises! 🚀**

_Remember: The goal is not just to complete, but to **learn**. If you don't understand something, ask. There are no silly questions._

---

## 📎 Appendix: Sample Data for Testing

### MySQL Sample Data

```sql
-- To test queries exercise 2
INSERT INTO production_batches (line_id, batch_code, product_name, target_quantity, actual_quantity, status, start_time)
VALUES 
(1, 'TEST_001', 'Widget Test', 1000, 900, 'completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'TEST_002', 'Widget Test', 1000, 950, 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 'TEST_003', 'Gadget Test', 500, 480, 'in_progress', NOW());

-- Verify
SELECT * FROM production_batches WHERE batch_code LIKE 'TEST_%';
```

### InfluxDB Sample Data

```bash
# InfluxDB CLI
influx write \
  -b iiot_sensors \
  -o iiot-class \
  -p s \
  'temperature,sensor_id=TEST_001 value=85.5'

influx write \
  -b iiot_sensors \
  -o iiot-class \
  -p s \
  'temperature,sensor_id=TEST_001 value=90.2'

# Verify
influx query 'from(bucket:"iiot_sensors") |> range(start: -1h) |> filter(fn: (r) => r.sensor_id == "TEST_001")'
```

---

**Version**: 1.0  
**Last Update**: February 2026  
**Instructor**: Christian Spana
