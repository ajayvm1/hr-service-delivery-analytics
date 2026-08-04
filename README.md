# HR Service Delivery & Master Data Management (MDM) Pipeline

## 📌 Executive Summary
Meridian Global Enterprise recently centralized its HR Service Delivery operations to manage human resources for a global workforce of 1,500 employees. However, leadership identified two critical operational failures: widespread Master Data corruption and severe Service Level Agreement (SLA) breaches. 

This project encompasses an end-to-end data pipeline (Python -> SQL -> Tableau) designed to clean the corrupted master data, track agent performance, and mathematically diagnose the root cause of the SLA failures.

## 🛠️ Phase 1: ETL & Master Data Management (Python)
The legacy system extract was plagued by poor data governance, requiring rigorous cleaning using `pandas` before analysis could begin.
* **String Standardization:** Consolidated fragmented categorical data (e.g., mapping ' HR ', 'hr', and 'Human Res' to a clean 'Human Resources' standard).
* **Timestamp Normalization:** Resolved conflicting EU/US date formats that were breaking time-series calculations.
* **Reverse-Engineering Corrupted Data:** Identified rows with literal `'########'` string errors in the creation dates. Successfully reverse-engineered and imputed these missing timestamps by applying a custom logic rule that subtracted one Business Day from the known SLA deadline.

## 📊 Phase 2: Diagnostic Analysis (SQL)
With a clean dataset, SQL was used to calculate actual resolution times and flag SLA breaches based on End-of-Day business logic.
* **Volume & Baseline:** Analyzed a total of 5,000 service tickets, revealing an overall company-wide SLA breach rate of 10.15%.
* **Isolating the Bottleneck:** Analysis by agent group and priority level exposed that while standard Case Managers maintained a 0.00% breach rate, the HR Escalations team suffered a 100.00% breach rate on Critical tickets.
* **Identifying the Root Cause:** Further investigation into the time allowances proved that the backend routing system was fundamentally flawed. The system was erroneously assigning the exact same time allowance (~46.6 hours) to all tickets, regardless of whether they were "Low" or "Critical" priority.

## 📈 Phase 3: Operational Dashboard (Tableau)
Developed a dynamic, interactive dashboard to visualize the workflow bottlenecks and present the systemic SLA flaw to leadership.
* Built custom calculations to separate human performance (Actual Resolution Time) from system parameters (SLA Allowance).
* Utilized dual-axis donut charts with action filters to visualize downstream departmental impact without cluttering the UI.
* Designed an executive-level layout to track Month-over-Month volume trends alongside active agent workload queues.

## 🧠 Diagnostic Insights
While the company-wide average resolution time appears healthy at 35.68 hours, this aggregate metric masks a severe departmental divide caused by static workflow routing:
* **The "Late-Stage" Escalation Flaw:** The current system uses a static, nature-based priority system. Because tickets are not escalating dynamically as time passes, the HR Escalations team is receiving tickets only *after* or immediately before the End-of-Day SLA is breached. This reactive routing results in a severe bottleneck, causing the Escalations team to average 121.18 hours per resolution. 
* **Core Workforce Efficiency:** The standard HR Case Managers are highly efficient, maintaining a 0% breach rate with an average resolution time of ~25 to ~26 hours across all Low, Medium, and High priority tickets. 

## 💡 Strategic Recommendations

**1. Implement Dynamic Time-Based Escalation**
* Transition from a purely static priority model to a dynamic routing system. 
**1. Implement Dynamic Time-Based Escalation (Countdown Logic)**
* Transition from a purely static priority model to a dynamic routing system based on the time remaining before the SLA deadline. 
* *Proposed Logic:* Divide the ~48-hour "End-of-Next-Day" SLA window into three equal 16-hour blocks, actively counting down to the deadline: 
  * `> 32 hours until deadline` = **Low**
  * `16 to 32 hours until deadline` = **Medium**
  * `< 16 hours until deadline` = **High**
  * `0 hours / Deadline Passed` = **Critical**
* *Rollout Strategy:* To prevent operational disruption, this dynamic time-based system should run in parallel with the current categorical system during an A/B testing phase using small ticket samples.

**2. Workforce Reallocation & Cross-Training**
* The HR Escalations team is currently understaffed to handle the volume of critical system failures. Management must assign additional agents to this group.
* * **The "Late-Stage" Routing Flaw:** On the surface, the HR Escalations team appears to be severely underperforming with an average resolution time of 121.18 hours (compared to ~26 hours for standard Case Managers). However, custom SQL analysis revealed a structural routing failure: Escalation agents are only receiving Critical tickets *after* the ~46-hour SLA deadline has already passed. 
* **Compounding Ticket Complexity:** This routing delay is compounded by the nature of the work. Because the automated system applies a flat ~46-hour deadline to all tiers, complex escalations are given the exact same time allowance as simple routine requests. This guarantees that Escalation agents mathematically fail the SLA before they even begin, resulting in an average completion time of 73.4 hours *past* the deadline.
* Promote from within: Leverage top-performing HR Case Managers for cross-training. Agents like **Priya Sharma** (highest overall closure volume at 730 tickets) and **Alex Mercer** (cleared the highest volume of High-priority tickets at 189) should be upskilled to intercept and handle Critical-level tickets.
* Authorize the HR Escalations team to proactively pull "High" priority tickets from the queue *before* they automatically escalate to "Critical" status, smoothing out the workload distribution.

##: Future Enhancements (Predictive Sub-Routing)
Once the dynamic time-based escalation system is stabilized in production, the next maturity phase for the HR Service Delivery model is **Weighted Sub-Prioritization**. 

Deep-dive interactive analysis using the Tableau dashboard revealed that SLA breach rates fluctuate heavily based on the intersection of `Location + Department + Request Topic`. 
* **The Granular Insight:** A "Leave Request" from the Finance department in Singapore experiences a 15.38% breach rate, whereas the exact same request from the Finance department in New York only breaches at 4.84%.
* **The Phase 2 Recommendation:** Introduce internal routing weights within the dynamic priority tiers. The system should automatically flag historically high-risk combinations (e.g., Singapore + Finance + Leave) and place them at the very top of the queue within their current priority level. This ensures equitable, data-driven service delivery across all global offices.


  
