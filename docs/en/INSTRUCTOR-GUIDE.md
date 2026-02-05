# Instructor Guide - Databases in IIoT

> 🇺🇸 **English** | [🇪🇸 Español](../es/GUIA-INSTRUCTOR.md)

**Course**: Use of Relational and Non-Relational Databases in Operational Technologies (IIoT)  
**Duration**: 60 minutes  
**Audience**: 7th Year Students - Electronic Engineering  
**University**: Ecuador

---

## 🎯 Introduction for the Instructor

This guide provides everything needed to teach an effective class on databases in IIoT, including:

- ✅ Detailed chronological structure (60 minutes)
- ✅ Suggested content for 15-20 slides
- ✅ Pedagogical notes by section
- ✅ Proven analogies for complex concepts
- ✅ Live demonstration script (15 min)
- ✅ FAQ management
- ✅ Troubleshooting during presentation
- ✅ Assessment materials

### Learning Objectives

By the end of this class, students will be able to:

1. **Identify** differences between SQL and NoSQL databases
2. **Explain** the concept of Polyglot Persistence and its application in IIoT
3. **Select** the appropriate database type according to data characteristics
4. **Understand** ACID properties and their importance in transactional systems
5. **Apply** MQTT as a communication protocol in IIoT architectures

---

## 📅 Pre-Class Preparation

### 1-2 Days Before

- [ ] Review this complete guide
- [ ] Download/clone Docker project
- [ ] Run `docker compose up -d` for initial test
- [ ] Verify access to all services (Node-RED, Grafana, Adminer, InfluxDB UI)
- [ ] Familiarize yourself with Node-RED flows
- [ ] Test sample queries in MySQL and InfluxDB
- [ ] Prepare presentation from suggested slides (PowerPoint/Google Slides)
- [ ] Prepare computer: open browser tabs, clipboard with queries

### 30 Minutes Before Class

- [ ] Start Docker system: `docker compose up -d`
- [ ] Verify all services healthy: `docker compose ps`
- [ ] Open in browser:
  - Node-RED: http://localhost:1880
  - Grafana: http://localhost:3000 (login admin/admin)
  - Adminer: http://localhost:8080
  - InfluxDB UI: http://localhost:8086
- [ ] Open terminal with `mosquitto_sub` ready
- [ ] Have sample queries in clipboard/notepad
- [ ] Projector/screen connected and tested
- [ ] Audio working (if there are videos)

### Contingency Plan

**If demo fails:**
- Use pre-captured screenshots
- Show short pre-recorded videos
- Code walkthrough without execution
- Extend theoretical section and Q&A

---

## ⏱️ Class Structure (60 minutes)

### Plan A - Ideal (60 min available)

| Time | Section | Content | Slides |
|------|---------|---------|--------|
| 0-5 min | **Introduction** | IIoT context, Industry 4.0, objectives | 1-3 |
| 5-20 min | **SQL** | Relational model, ACID, when to use | 4-8 |
| 20-35 min | **NoSQL** | Types, TSDB, when to use | 9-13 |
| 35-40 min | **Polyglot** | Hybrid architecture, MQTT | 14-16 |
| 40-55 min | **LIVE Demo** | 🔴 System running in real-time | - |
| 55-60 min | **Q&A** | Questions and closing | 17-20 |

### Plan B - Adjusted (55 min effective)

If SQL/NoSQL sections extend:

| Time | Section | Adjustment |
|------|---------|------------|
| 0-5 min | Intro | Maintain |
| 5-17 min | SQL | Reduce examples (-3 min) |
| 17-29 min | NoSQL | Focus only on TSDB (-3 min) |
| 29-32 min | Polyglot | More concise (-2 min) |
| 32-50 min | Demo | **PRIORITY** - extend (+3 min) |
| 50-55 min | Q&A | Maintain |

### Plan C - Emergency (demo fails)

- 0-40 min: Complete theory (slides with screenshots)
- 40-50 min: Pre-recorded videos (2-3 min each)
- 50-60 min: Extended Q&A

---

## 📊 Suggested Slide Content

### **SLIDE 1: Cover**

```
┌─────────────────────────────────────────┐
│  Use of Relational and Non-Relational  │
│   Databases in Operational             │
│     Technologies (IIoT)                 │
│                                         │
│  Universidad Ecuador                    │
│  7th Year - Electronic Engineering      │
│                                         │
│  [University Logo]                      │
│                                         │
│  Instructor: [Name]                     │
│  Date: [DD/MM/YYYY]                     │
└─────────────────────────────────────────┘
```

**Instructor Note**: Introduce yourself briefly (30 sec). Mention IIoT experience if applicable.

---

### **SLIDE 2: Agenda**

```
📋 Agenda (60 minutes)

1. Introduction: IIoT and Industry 4.0 (5 min)
2. Relational Databases (15 min)
   • SQL model
   • ACID properties
   • IIoT use cases
3. NoSQL Databases (15 min)
   • NoSQL types
   • Time-Series Databases
   • Advantages for IIoT
4. Polyglot Persistence (5 min)
   • Hybrid architecture
   • MQTT in IIoT
5. Live Demonstration (15 min) 🔴
6. Questions and Answers (5 min)
```

**Instructor Note**: "We'll have a LIVE demonstration of a real IIoT system running. The most important part is seeing how these technologies work together."

---

### **SLIDE 3: Context - Industry 4.0 and IIoT**

```
🏭 The Industrial Data Revolution

INDUSTRY 4.0
┌──────────────────────────────────────┐
│ Physical World + Digital World       │
│                                      │
│ • Smart factories                    │
│ • Predictive maintenance             │
│ • Real-time optimization             │
│ • Digital twins                      │
└──────────────────────────────────────┘

IIoT: Industrial Internet of Things
• 75 billion devices by 2025
• Millions of sensors generating data 24/7
• Challenge: How to store and analyze?

💡 This class: Practical database solutions
```

**Suggested image**: Factory with highlighted sensors, network connections

**Instructor Note**: 
- Mention local Ecuador examples: smart agriculture, Galápagos environmental monitoring, oil industry
- Connect to reality: "Your phones have sensors (accelerometer, GPS). Multiply that by 1000 in a factory."
- Rhetorical question: "How much data does a factory generate in a day? Billions of records."

---

### **SLIDE 4: Types of Industrial Data**

```
📊 Data Classification in IIoT

┌──────────────────┬─────────────────┬──────────────────┐
│ DATA TYPE        │ EXAMPLES        │ CHARACTERISTICS  │
├──────────────────┼─────────────────┼──────────────────┤
│ Time-Series      │ Temperature     │ • High frequency │
│                  │ Pressure        │ • Time-dependent │
│                  │ Vibration       │ • Large volume   │
│                  │ Current         │ • Continuous     │
├──────────────────┼─────────────────┼──────────────────┤
│ Transactional    │ Production      │ • Low frequency  │
│ Structured       │ Batches         │ • Fixed structure│
│                  │ Quality         │ • ACID integrity │
│                  │ Events          │ • Discrete       │
├──────────────────┼─────────────────┼──────────────────┤
│ Configuration    │ Sensors         │ • Few changes    │
│ Metadata         │ Machines        │ • Hierarchical   │
│                  │ Recipes         │ • Reference      │
└──────────────────┴─────────────────┴──────────────────┘

🎯 Each type requires different storage strategy
```

**Instructor Note**:
- "Imagine a thermometer: it records temperature every second. That's time-series."
- "Now imagine a production order: created once, has unique number, status. That's transactional."
- Ask class: "What type of data is a sensor location? [Answer: Configuration/Metadata]"

---

### **SLIDE 5: Relational Databases - SQL Model**

```
🗄️ Relational Databases (SQL)

KEY CHARACTERISTICS
┌─────────────────────────────────────┐
│ ✓ Model: Tables, Rows, Columns     │
│ ✓ Schema: Rigid, defined           │
│ ✓ Relations: Foreign Keys (JOINs)  │
│ ✓ Integrity: ACID properties       │
│ ✓ Scalability: Vertical (↑ RAM)    │
└─────────────────────────────────────┘

POPULAR EXAMPLES
MySQL • PostgreSQL • SQL Server • Oracle

APPLICATION IN IIoT
• Production data (batches, units)
• Master information (machines, users)
• Transactional events (start/end)
• Quality management (inspections)
```

**Suggested diagram**: Simple SQL table with visual FK

**Instructor Note**:
- "SQL has been around for 50+ years. It's mature, reliable, proven."
- "Like an Excel spreadsheet but with superpowers: automatic validations, guaranteed relationships."
- Mention: "In Ecuador, banks use SQL. Why? They need guarantees that your money won't disappear."

---

### **SLIDE 6-7: ACID - The Heart of SQL**

```
💳 ACID Properties - Transactional Guarantees

╔═══════════════════════════════════════════════════╗
║ A - ATOMICITY                                     ║
╠═══════════════════════════════════════════════════╣
║ All or Nothing                                    ║
║ Example: Bank transfer                            ║
║   ✓ Debit Account A + Credit Account B            ║
║   ✗ If credit fails → Complete Rollback           ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ C - CONSISTENCY                                   ║
╠═══════════════════════════════════════════════════╣
║ Rules always valid                                ║
║ Example: Balance cannot be negative               ║
║   ✓ Constraints prevent invalid states            ║
║   ✗ DELETE blocked if violates Foreign Key        ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ I - ISOLATION                                     ║
╠═══════════════════════════════════════════════════╣
║ Transactions don't interfere                      ║
║ Example: 2 people at ATM simultaneously           ║
║   ✓ Each sees their own transaction               ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ D - DURABILITY                                    ║
╠═══════════════════════════════════════════════════╣
║ COMMIT = Permanent                                ║
║ Example: Power outage after COMMIT                ║
║   ✓ Data survives power failure                   ║
╚═══════════════════════════════════════════════════╝
```

**SLIDE 7: ACID in Industrial Production**

```
🏭 ACID in IIoT - Practical Example

SCENARIO: Production Batch Registration

START TRANSACTION;
  
  -- 1. Create batch
  INSERT INTO production_batches (line_id, batch_code, ...)
  VALUES (1, 'BATCH_2026_010', ...);
  
  -- 2. Register start event
  INSERT INTO production_events (batch_id, event_type, ...)
  VALUES (LAST_INSERT_ID(), 'start', ...);
  
  -- 3. If quality_check FAILS...
  IF quality_score < 7.0 THEN
    ROLLBACK;  -- ⬅️ ATOMICITY: Undo EVERYTHING
  ELSE
    COMMIT;    -- ✅ Save permanently
  END IF;

🎯 Without ACID: We could have batches without events
               or events without batches = CHAOS
```

**Instructor Note**:
- **Star analogy**: "Paying restaurant bill with friends, splitting proportionally. If one friend can't pay their part, ENTIRE transaction is canceled. That's Atomicity."
- Then ask: "What would happen without ACID in production? Chaos: orphan orders, inconsistent inventory, impossible audits."
- **Micro demo**: "In the demonstration you'll see this in action with a 'Bad Transaction' button."

---

### **SLIDE 8: When to Use SQL in IIoT**

```
✅ USE SQL WHEN...

1. Transactional Data
   • Production batches
   • Work orders
   • Quality inspections

2. Complex Relationships
   • Line → Batches → Inspections → Events
   • Foreign Keys guarantee integrity

3. Critical Integrity
   • Audits (traceability)
   • Regulatory compliance
   • Financial reports

4. Relational Queries
   • JOINs between multiple tables
   • Aggregations with GROUP BY
   • Complex reports

❌ NOT OPTIMAL FOR...
   • High frequency (>100 writes/second)
   • Pure time-series
   • Unstructured data
```

**Instructor Note**: "Rule of thumb: If you need to ROLLBACK, you probably need SQL."

---

### **SLIDE 9: NoSQL Databases**

```
🌐 NoSQL: Not Only SQL

CHARACTERISTICS
• Flexibility: Dynamic schema
• Scalability: Horizontal (+ servers)
• Variety: Multiple data models
• Performance: Optimized for specific cases

4 MAIN NoSQL TYPES

┌─────────────────┬──────────────────────────────┐
│ TYPE            │ USE IN IIoT                  │
├─────────────────┼──────────────────────────────┤
│ 🗝️ KEY-VALUE    │ Fast cache (Redis)           │
│                 │ Sessions, configuration      │
├─────────────────┼──────────────────────────────┤
│ 📄 DOCUMENT     │ Variable recipes (MongoDB)   │
│                 │ Unstructured logs            │
├─────────────────┼──────────────────────────────┤
│ 🕸️ GRAPH        │ Device network (Neo4j)       │
│                 │ Complex relationships        │
├─────────────────┼──────────────────────────────┤
│ ⏰ TIME-SERIES  │ IIoT sensors (InfluxDB)      │
│   ⭐ STAR        │ ← Most important for IIoT    │
└─────────────────┴──────────────────────────────┘
```

**Instructor Note**: "NoSQL does NOT mean No-SQL, it means Not-ONLY-SQL. It's complementary, not a replacement."

---

### **SLIDE 10-11: Time-Series Databases - IIoT Star**

```
⏰ Time-Series Databases (TSDB)

WHAT ARE THEY?
Databases optimized for time-indexed data

DATA STRUCTURE
┌─────────────────────────────────────────┐
│ Measurement: "temperature"              │
│                                         │
│ Time                Value   Sensor_ID   │
│ ────────────────   ─────   ─────────    │
│ 2026-02-03 10:00   65.2°C  TEMP_001     │
│ 2026-02-03 10:01   65.5°C  TEMP_001     │
│ 2026-02-03 10:02   66.1°C  TEMP_001     │
│ ...                                     │
│ (86,400 readings/day at 1 reading/sec)  │
└─────────────────────────────────────────┘

EXAMPLES: InfluxDB, TimescaleDB, Prometheus
```

**SLIDE 11: TSDB vs SQL - Comparison**

```
⚔️ Efficiency: TSDB vs Traditional SQL

SCENARIO: Temperature sensor every 1 second

┌──────────────────┬──────────┬──────────┬────────────┐
│                  │  MySQL   │ InfluxDB │ ADVANTAGE  │
├──────────────────┼──────────┼──────────┼────────────┤
│ Records/hour     │  3,600   │  3,600   │ Equal      │
│ Storage          │  1.2 MB  │  0.15 MB │ 8x smaller │
│ Query: Avg 1h    │  500 ms  │  50 ms   │ 10x faster │
│ Compression      │  Manual  │  Auto    │ Built-in   │
│ Downsampling     │  Complex │  Native  │ Easy       │
└──────────────────┴──────────┴──────────┴────────────┘

ANATOMY OF EFFICIENCY
┌────────────────────────────────────────────┐
│ MYSQL (Row-Store)                          │
│ Row 1: [id, timestamp, temp, sensor, ...]  │
│ Row 2: [id, timestamp, temp, sensor, ...]  │
│ ↑ Each row has complete overhead           │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│ INFLUXDB (Column-Store)                    │
│ timestamps: [t1, t2, t3, ...]              │
│ values: [65.2, 65.5, 66.1, ...]            │
│ ↑ Columns compress better (similar values) │
└────────────────────────────────────────────┘

🎯 Annual scale: 1.3 GB vs 10.4 GB
```

**Instructor Note**:
- **Analogy**: "MySQL is like a library organizing books by complete author/title. TSDB is like a thermometer that only stores temperatures in order. Which is more efficient for temperature history? Obviously."
- "We'll show query speed in live demo."
- Mention: "In demo we'll see 3,600 records in ~50ms."

---

### **SLIDE 12: When to Use TSDB in IIoT**

```
✅ USE TIME-SERIES DB WHEN...

1. High Write Frequency
   • >10 readings/second per sensor
   • Multiple simultaneous sensors
   • Ex: Motor vibration 1000 Hz

2. Time-Based Queries
   • "Temperature last hour"
   • "Daily average last month"
   • "Detect anomalies in time window"

3. Differentiated Retention
   • Raw data: 30 days
   • Hourly aggregates: 1 year
   • Daily aggregates: 5 years

4. Automatic Downsampling
   • 1 sec → 1 min → 1 hour → 1 day
   • Reduces storage 99%+

IDEAL SENSORS FOR TSDB
🌡️ Temperature | 💨 Pressure | 📊 Vibration
⚡ Current    | 🌊 Flow     | 📏 Level
```

**Instructor Note**: "If the data has timestamp as primary attribute, it probably goes in TSDB."

---

### **SLIDE 13: Polyglot Persistence**

```
🔄 Polyglot Persistence: Best of Both Worlds

CONCEPT
Use multiple types of databases in a single
application, choosing the best tool for each
data type.

ANALOGY: Toolbox
┌──────────────────────────────────────┐
│ 🔨 Hammer → Nails                    │
│ 🪛 Screwdriver → Screws              │
│ 🪚 Saw → Cut wood                    │
│                                      │
│ ❌ NOT everything with hammer         │
│ ✅ Right tool for each job           │
└──────────────────────────────────────┘

TYPICAL IIoT ARCHITECTURE
┌──────────────────────────────────────┐
│ Sensor → MQTT → Processor            │
│                    ↓                  │
│            ┌───────┴───────┐         │
│            ↓               ↓         │
│       InfluxDB          MySQL        │
│      (time-series)  (transactions)   │
│            ↓               ↓         │
│            └───────┬───────┘         │
│                    ↓                  │
│                 Grafana               │
│            (visualization)            │
└──────────────────────────────────────┘
```

**Instructor Note**: "It's not competition, it's collaboration. Like having Excel AND Word, not Excel OR Word."

---

### **SLIDE 14: MQTT - The Language of IIoT**

```
📡 MQTT: Message Queuing Telemetry Transport

WHY MQTT?
• Lightweight: 2 byte headers (vs 200+ HTTP)
• Bidirectional: Real-time push
• Decoupled: Publishers ≠ Subscribers
• QoS Levels: Delivery guarantees
• Standard: ISO/IEC 20922

PUB/SUB ARCHITECTURE
┌────────────────────────────────────────┐
│         🏭 PUBLISHERS                   │
│    (Sensors, PLCs, Devices)            │
│         ↓   ↓   ↓   ↓                  │
│         └───┴───┴───┘                  │
│              ↓                          │
│      ☁️ BROKER (Mosquitto)              │
│              ↓                          │
│         ┌───┬───┬───┐                  │
│         ↓   ↓   ↓   ↓                  │
│        📊  🖥️  📱  💾                   │
│    SUBSCRIBERS                         │
│  (Apps, Databases, Dashboards)         │
└────────────────────────────────────────┘

ADVANTAGE: Sensors don't know who consumes
          Consumers don't know who publishes
```

**Instructor Note**:
- **Radio analogy**: "95.5 FM radio transmits (publish). Multiple cars tune in (subscribe). Radio doesn't know who's listening. Cars don't know each other. Turn off radio → cars wait or use last info (retained). Exactly MQTT."

---

### **SLIDE 15: Demonstration System Architecture**

```
🏗️ Complete IIoT System - What We'll See

DATA FLOW
┌────────────────────────────────────────────┐
│ 1️⃣ GENERATION                              │
│    Node-RED simulates sensors              │
│    Temp: 1/sec | Pressure: 2/sec          │
└──────────────────┬─────────────────────────┘
                   ↓ Publish MQTT
┌────────────────────────────────────────────┐
│ 2️⃣ COMMUNICATION                           │
│    Mosquitto Broker (Port 1883)            │
│    Topics: iiot/sensors/*                  │
└──────────────────┬─────────────────────────┘
                   ↓ Subscribe
┌────────────────────────────────────────────┐
│ 3️⃣ PROCESSING                              │
│    Node-RED                                │
│    Validates, transforms, routes           │
└─────────┬──────────────────────┬───────────┘
          ↓                      ↓
┌──────────────────┐   ┌──────────────────┐
│ 4️⃣ STORAGE       │   │ 4️⃣ STORAGE       │
│    InfluxDB      │   │    MySQL         │
│    Temp/Pressure │   │    Production    │
│    High Freq.    │   │    Quality       │
└─────────┬────────┘   └────────┬─────────┘
          └───────┬──────────────┘
                  ↓ Read
┌────────────────────────────────────────────┐
│ 5️⃣ VISUALIZATION                           │
│    Grafana Dashboards                      │
│    Unified real-time data                  │
└────────────────────────────────────────────┘

✨ ALL running on Docker right now
```

**Instructor Note**: "This slide is a map of what you'll see. Reference during demo: 'Here we are in step 3, processing...'"

---

### **SLIDE 16: Transition to Demo**

```
🎬 Live Demonstration

WHAT YOU'LL SEE (15 minutes):

✅ Real IIoT system running
✅ Data flowing in real-time via MQTT
✅ Node-RED orchestrating everything
✅ Simultaneous writing to InfluxDB and MySQL
✅ Comparative queries (speed)
✅ ACID demonstration (transactions)
✅ Grafana visualizing both DBs

🎯 OBJECTIVE
See with your own eyes why we need
MULTIPLE databases in IIoT

📝 Take notes of what seems interesting
   to ask about later

[PAUSE FOR SCREEN SETUP]
```

---

### **SLIDE 17: Exercises for Students**

```
📝 Practical Exercises

EXERCISE 1: DB Selection (3 min)
5 scenarios → Choose MySQL or InfluxDB

EXERCISE 2: Queries (Homework)
• 3 SQL queries (MySQL)
• 3 Flux queries (InfluxDB)

EXERCISE 3: Design (Advanced)
Design schema for bottling plant

EXERCISE 4: Node-RED (Bonus)
Create cross-database flow

EXERCISE 5: Python MQTT (Bonus)
Data publisher script

📂 All in /exercises folder of project
🎯 Evaluation: See rubrics in EXERCISES.md
```

---

### **SLIDE 18: Additional Resources**

```
📚 Resources for Further Learning

DOCUMENTATION
• Docker: docs.docker.com
• InfluxDB: docs.influxdata.com
• MySQL: dev.mysql.com/doc
• MQTT: mqtt.org
• Grafana: grafana.com/docs

TUTORIALS
• InfluxDB University (free)
• MySQL Tutorial (w3schools)
• MQTT Essentials (HiveMQ)

COMPLETE PROJECT
• Repository with all code
• README with step-by-step instructions
• Python sample scripts
• Commented sample queries

OPTIONAL ADVANCED
• Factory I/O (industrial simulator)
• Integration with OPC-UA
• See project documentation
```

---

### **SLIDE 19: Questions and Discussion**

```
❓ Questions and Answers

Topics for discussion:
• Real project applications
• Use cases in Ecuador
• Integration with existing systems
• Implementation costs
• Scalability

💡 There are no stupid questions
   Only concepts that haven't been explained well

📧 Contact for post-class questions:
   [instructor email]

🔗 Links to project and resources:
   [repository/drive URL]
```

---

### **SLIDE 20: Closing**

```
🎓 Summary - Take Away Messages

1️⃣ SQL ≠ NoSQL is not competition
   It's collaboration (Polyglot Persistence)

2️⃣ High frequency + time = TSDB
   Transactions + relationships = SQL

3️⃣ MQTT is the de facto standard in IIoT
   Lightweight, decoupled, reliable

4️⃣ Grafana unifies visualization
   One view, multiple sources

5️⃣ Docker facilitates complete setup
   Entire system in minutes

🚀 NEXT STEPS
• Download project
• Experiment at home
• Complete exercises
• Apply to final project

Thank you for your attention!
```

---

## 📝 Detailed Pedagogical Notes

### Section 1: Introduction (5 min)

**Objectives**:
- Capture attention
- Establish relevance
- Create context

**Key Points**:
1. IIoT is not futuristic, it's present
2. Ecuador has real use cases
3. Problem: massive data volume

**Transition**: "Before solutions, let's understand data types..."

**Provocative Questions**:
- "How many sensors do you think a modern factory has?" [Answer: Thousands]
- "How often do they send data?" [Answer: Seconds or less]

**Common Confusion Alert**: Students may think IIoT = IoT. Clarify that IIoT has stricter requirements (reliability, real-time, security).

---

### Section 2: SQL (15 min)

**Objectives**:
- Understand relational model
- Comprehend ACID deeply
- Identify IIoT use cases

**Internal Timing**:
- 5 min: Relational model + characteristics
- 7 min: ACID (critical, don't rush)
- 3 min: IIoT use cases

**ACID Focus** (VERY IMPORTANT):

**A - Atomicity**:
- Restaurant analogy (split bill)
- Code example: START TRANSACTION / ROLLBACK
- In demo: Show "Bad Transaction" button

**C - Consistency**:
- Demonstrate constraint violation
- Example: Try DELETE with FK
- "Database is security guard"

**I - Isolation**:
- Optional if time allows
- Mention briefly: "2 users, same row, don't interfere"

**D - Durability**:
- Simpler: "COMMIT = carved in stone"
- "Power outage doesn't lose data post-COMMIT"

**Questions for Engagement**:
- "What happens if you delete a production line that has batches?" [Answer: FK constraint error]
- "Why do banks use SQL?" [Answer: ACID guarantees money doesn't disappear]

---

### Section 3: NoSQL (15 min)

**Objectives**:
- Understand NoSQL flexibility
- Focus on TSDB (most relevant for IIoT)
- See performance advantages

**Internal Timing**:
- 3 min: NoSQL intro and 4 types
- 9 min: TSDB (deep dive)
- 3 min: Use cases and decision

**TSDB - Critical Points**:

1. **Columnar structure** (key to performance):
   - Show visually difference row vs column store
   - Explain why columns compress better
   - Similar consecutive values = high compression

2. **Concrete comparison**:
   - Use real numbers: 1.2 MB vs 150 KB
   - Query speed: 500ms vs 50ms (10x)
   - Scale to one year for impact

3. **Downsampling**:
   - 1 second → 1 minute → 1 hour → 1 day
   - Reduces 86,400 records/day → 1 record/day
   - Maintains trends, loses detail

**TSDB Analogy**:
"Medical thermometer specialized in temperature vs generic notebook. Obviously thermometer is better for temperature history."

**Questions**:
- "How many records does a sensor generate at 1 Hz in a day?" [86,400]
- "What about 100 sensors?" [8,640,000]
- "Do we need 1-second detail from 5 years ago?" [No]

---

### Section 4: Polyglot Persistence + MQTT (5 min)

**Objectives**:
- Unify previous concepts
- Introduce MQTT briefly
- Prepare for demo

**Internal Timing**:
- 2 min: Polyglot concept
- 2 min: MQTT essentials
- 1 min: Transition to demo

**Polyglot Persistence**:
- NOT competition, collaboration
- Toolbox analogy (strong)
- Show data flow diagram

**MQTT**:
- Don't go too deep (there's a separate guide)
- Focus on: lightweight, decoupled, standard
- Radio analogy is perfect

**Critical Transition**:
"Enough theory. Now... [dramatic pause] ...let's see this in ACTION." [Switch to demo screen]

---

## 🎬 LIVE Demonstration Script (15 min)

See **DEMONSTRATION-GUIDE.md** file for detailed minute-by-minute script.

**Structure**:
1. Min 0-2: Show system running
2. Min 3-5: Real-time MQTT data flow
3. Min 6-9: Query comparison
4. Min 10-12: ACID demo
5. Min 13-15: Integrated polyglot value

**Mantra**: "Don't explain every click, explain the CONCEPT."

---

## ❓ FAQ Management

### During Presentation

**Q: "Why not just use MySQL for everything?"**
A: "Excellent question. [Show comparison slide]. MySQL for 86,400 readings/day from one sensor = 1.2 MB/day uncompressed. Multiply by 100 sensors by 365 days. InfluxDB: 8x less space + 10x faster queries. At scale, this is the difference between economically viable and impossible."

**Q: "Is MQTT secure?"**
A: "In this demo: no (anonymous). Production: yes. MQTT supports TLS/SSL, username/password authentication, certificates. Like HTTP vs HTTPS. Educational simplicity here, production security there."

**Q: "How much does InfluxDB cost?"**
A: "InfluxDB has open-source version (free). Cloud has free tier for small projects. Enterprise: ~$8-10/server/month. MySQL similar. Not prohibitive."

**Q: "Is Factory I/O necessary?"**
A: "No. System works complete without it using integrated simulators. Factory I/O is optional advanced for those who want to experiment with real OPC-UA."

**Q: "Is this used in real industry?"**
A: [Give concrete examples]
- Tesla uses InfluxDB for vehicle telemetry
- Amazon uses polyglot persistence (DynamoDB + RDS + Redshift)
- MQTT is standard in automotive (Connected Cars)
- Siemens, ABB, Schneider use these architectures

**Q: "Why Node-RED and not Python directly?"**
A: "Both are valid. Node-RED: visual, fast for prototyping, graphical debugging, deployment without code. Python: more flexible, better for ML, preferred by data scientists. In demo we use Node-RED for visual clarity. Project includes Python scripts too."

**Q: "What happens if Mosquitto crashes?"**
A: "Good architecture concern. MQTT has persistent sessions. QoS 1/2 messages are resent when broker returns. Production: multiple brokers (clustering), load balancing. Like having a backup generator."

### Post-Class (Email/Office Hours)

**Q: "I can't run Docker on my laptop"**
A: Verify:
- Docker Desktop installed and running
- Minimum 4GB RAM assigned to Docker
- Ports not occupied (1880, 3306, 8086, 3000, 1883)
- See troubleshooting section in README

**Q: "How do I apply this to my final project?"**
A: Guide according to their project:
- Identify data types they handle
- Map to SQL or NoSQL according to characteristics
- Suggest specific architecture
- Offer to review design in office hours

---

## 🔧 Troubleshooting During Presentation

### Demo Fails Completely

**Symptoms**: Services don't start, blank screen

**Immediate Action**:
1. Don't panic (maintain calm)
2. "While I resolve this, let's see the concepts with screenshots..."
3. Use slides with pre-made captures
4. Continue theoretical explanation
5. Attempt fix in background
6. If not resolved in 2 min: continue with screenshots/videos

**Prevention**: Have screenshots and short videos pre-recorded as backup

### Port Occupied

**Symptom**: Error "port already allocated"

**Quick Fix**:
```bash
# Terminal visible on projector
docker compose down
docker compose up -d
```

While restarting: "This happens. In production they use health checks and auto-restart. Gives us a chance to talk about resilience..."

### Unhealthy Service

**Symptom**: `docker compose ps` shows Restarting

**Fix**:
```bash
docker compose logs [service]
# Identify error
docker compose restart [service]
```

If not resolved quickly: skip that service and continue with others.

### No Data Appears in Grafana

**Probable Cause**: Node-RED flows not deployed

**Fix**:
1. Open Node-RED
2. Click "Deploy" (red button)
3. Wait 10 seconds
4. Refresh Grafana

**While waiting**: "This demonstrates importance of state in distributed systems. Deploy is like 'save changes'..."

---

## 📊 Assessment Materials

### Exercise Rubrics

See **EXERCISES.md** file for detailed rubrics.

**Suggested Distribution**:
- Exercise 1 (DB Selection): 5 pts
- Exercise 2 (Queries): 15 pts
- Exercise 3 (Design): 20 pts
- Exercise 4 (Node-RED): 15 pts
- Exercise 5 (Python MQTT): 10 pts bonus

**Total**: 55 pts + 10 bonus = 65 pts max

**Conversion** to university scale (example out of 10):
- 55-65 pts → 10/10
- 45-54 pts → 9/10
- 35-44 pts → 8/10
- Etc.

### Evaluation Criteria

**Conceptual Knowledge** (40%):
- Correctly identifies when to use SQL vs NoSQL
- Explains ACID properties
- Understands polyglot persistence architecture

**Practical Application** (40%):
- Writes functional queries
- Designs appropriate schemas
- Implements flows correctly

**Documentation** (20%):
- Justifies design decisions
- Comments code appropriately
- Explains reasoning

---

## 🎯 General Pedagogical Tips

### Guy Kawasaki's 10-20-30 Rule

- **10 slides** key (minimum - here we have 20 total)
- **20 minutes** dense content maximum
- **30 pt** minimum font size

### Maintain Attention

- **Rhetorical question every 5 min**: "What would happen if...?"
- **Medium change every 10 min**: Slide → Demo → Slide
- **Appropriate humor**: "SQL is like a toxic ex: very structured, won't let you go (foreign keys)"

### Inverted Learning Principle

1. **First**: Show demo (visual impact)
2. **Then**: Explain theory (now has context)
3. **Finally**: Exercises (application)

### Connect to Reality

- "You can use this in your thesis"
- "Companies in Ecuador seek people with these skills"
- "Factory I/O optional, but helps if interested in automation"

### Strategic Pauses

After dense concepts:
- "Clear so far?"
- "Any questions before continuing?"
- Wait **3 seconds minimum** (uncomfortable silence OK)

---

## 📧 Post-Class: Follow-up

### Within 24 Hours

- [ ] Send summary email with:
  - Slides in PDF
  - Link to project repository
  - Additional resources
  - Exercise submission deadline

### Create Discussion Space

- Forum/thread for exercise questions
- Discord/Slack optional for community
- Specific office hours (e.g., Friday 2-4 PM)

### Follow-up Class (Optional)

30 minutes "Showcase" best solutions:
- Students present exercises
- Discussion of different approaches
- Constructive feedback

### Feedback Survey

Send short survey (5 min):
- What was most useful?
- What was confusing?
- What to add for future?
- Was pace appropriate?

Use feedback to improve next iteration.

---

## 🚀 Extensions for Advanced Students

### Level 1 (Intermediate)
- Integrate complete Factory I/O
- Add Redis as cache layer
- Implement Grafana alerts (email)

### Level 2 (Advanced)
- Telegraf for system metrics
- Node-RED with authentication
- Custom Flask/React dashboard

### Level 3 (Expert)
- Kubernetes deployment
- Kafka for event streaming
- Machine Learning with historical data

---

## 📚 Pedagogical References

### Recommended Papers
- "Teaching Industrial IoT" - IEEE
- "Database Selection in Industry 4.0" - ACM

### Books
- "Industrial Internet of Things" - Alasdair Gilchrist
- "Time Series Databases" - Ted Dunning & Ellen Friedman

### Complementary Online Courses
- Coursera: IoT and Data Management
- edX: Database Systems
- InfluxDB University (free)

---

## ✅ Final Pre-Class Checklist

**1 Hour Before**:
- [ ] Docker system running
- [ ] All services healthy
- [ ] Browser tabs open
- [ ] Terminal prepared
- [ ] Queries in clipboard
- [ ] Projector working
- [ ] Audio OK
- [ ] Water/coffee available
- [ ] Backup plan ready

**5 Min Before**:
- [ ] Close notifications
- [ ] Silence phone
- [ ] Put laptop in "Do Not Disturb"
- [ ] Verify WiFi stable
- [ ] Presentation in fullscreen
- [ ] Open Node-RED in preview tab

**During Class**:
- [ ] Maintain high energy
- [ ] Pause for questions
- [ ] Monitor time
- [ ] Adapt to audience
- [ ] Enjoy teaching! 😊

---

**Success in your class! 🎓**

This guide prepares you completely. Remember: students learn more from your enthusiasm than from technical perfection. If something fails, it's an opportunity to teach real troubleshooting.

_"The best teacher is not one who never makes mistakes, but one who knows how to handle errors with grace."_
