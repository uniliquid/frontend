ui.title(_"Introduction")

local lang = locale.get("lang")

ui.section(function()
  ui.sectionHead(function()
    ui.heading{ level = 1, content = _"Structured discussion" }
  end)
  ui.sectionRow(function()
    ui.heading{ level = 2, content = _"Initiatives and issues" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        LiquidFeedback ist kein Umfragesystem, es werden keine bereits vorher feststehenden Fragen gestellt. Statt dessen kann jeder Teilnehmer neue Initiativen starten, die Vorschläge und/oder Argumente umfassen. Sobald eine Initiative eingestellt wurde, können alle Teilnehmer alternative Initiativen mit Gegenvorschlägen starten. Alle zueinander in Konkrurrenz stehenden Initiativen bilden zusammen ein Thema. Sowohl Themen als auch Initiativen werden nummeriert. Themen erhalten hierbei vor der Nummer ein #-Zeichen (z. B. #123), während Initiativen durch ein führendes i gekennzeichnet sind (z. B. i456). Ein Thema kann mehrere Initiativen enthalten. Nur eine Initiative kann gewinnen.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        LiquidFeedback is no survey, it doesn't ask you predefined questions. Instead every participant is allowed to post new initiatives containing a proposal and/or reasoning. As soon as the initiative is posted, all other participants can create alternative initiatives with counter proposals and/or reasoning. A group of concurring initiatives forms an issue. Issues in LiquidFeedback are numbered with a hash sign (e.g. #123) while initiatives are numbered with a leading "i" character (i456). In short: One issue may contain multiple initiatives. Only one initiative can win.
      ]] }
    end
      
    ui.heading{ level = 2, content = _"Subject areas" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Themen werden immer einem Themenbereich zugeordnet. Dies dient der Strukturierung der Diskussion und des Entscheidungsprozesses.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        Issues are always assigned to a subject area in order to structure the discussion and decision process.
      ]] }
    end
    ui.heading{ level = 2, content = _"Organizational units" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Gliederungen ermöglichen Diskussionen und Entscheidungen auch für Teilmengen der Benutzer (z. B. Gliederungen einer Organisation). In jeder Gliederung können eigene Themenbereiche zur Verfügung stehen.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        To allow discussions and decisions by sub groups of participants (e.g. by the members of a subdivision of an organization), participants can be assigned to different units. Every organizational unit can have its own subject areas.
      ]] }
    end
    ui.heading{ level = 2, content = _"Rules of procedure" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Ein Regelwerk definiert Fristen, Quoren und erforderliche Mehrheiten. Initiatoren wählen bei Erstellung eines Themas ein geeignetes Verfahren, das dem verfolgten Zweck entspricht.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        A policy defines the timing, quorums and required majorities for an issue in LiquidFeedback. Initiators choose the fitting policy for their purpose when creating a new issue.
      ]] }
    end
  end )
end )
ui.section(function()
  ui.sectionHead(function()
    ui.heading{ level = 1, content = _"4 phases of a decision" }
  end)
  ui.sectionRow(function()
    ui.heading{ level = 2, content = _"(1) Admission phase" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Nicht jedes neue Thema wird auf ein Mindestinteresse der Teilnehmer stoßen. Daher muss ein neues Thema von einer vorab festzulegenden Mindestanzahl Teilnehmer als diskussionswürdig betrachtet  werden, um für die Diskussionsphase zugelassen zu werden. Andernfalls wird das Thema am Ende der Zulassungsphase abgebrochen und nicht weiter behandelt.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        As every participant can open a new issue in LiquidFeedback, not all of them will be intersting for at least a minimum of the participants. Therefore new issues need to gain a given quorum of supporters to become accepted for further discussion. Issues which do not reach the necessary quorum will be closed at the end of the admission phase.
      ]] }
    end
    ui.heading{ level = 2, content = _"(2) Discussion phase" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Während der Diskussionsphase arbeiten Initiativen auf die Verbesserung des Vorschlags und die Vervollkommnung der Argumentation hin, um die erforderliche Mehrheit zu erreichen und sich gegen eventuell vorhandene alternative Initiativen durchzusetzen.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        During the discussion phase all initiatives try to improve their proposals and reasoning to gain more supporters. The aim is to eventually reach the necessary majority and to beat alternative initiatives.
      ]] }
    end
    ui.heading{ level = 2, content = _"(3) Verification phase" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Alle in dieser Phase angezeigten Initiativtexte können nicht mehr verändert werden. Neue Initiativen können gestartet aber ebenfalls nicht mehr geändert werden. Dieses Vorgehen schützt die Teilnehmer vor überraschenden Änderungen in letzter Minute.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        During the verification phase, initiative drafts with the proposal and reasoning become final and cannot be changed any more. So everyone can double check everything. In case of some last minute situation, it is still possible to add competing initiatives. But they cannot be edited again and need to gain supporters from scratch.
      ]] }
    end
    ui.heading{ level = 2, content = _"(4) Voting phase" }
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Jede Initiative, die eine Mindestanzahl an Unterstützern erreicht, wird zur Abstimmung zugelassen und erscheint auf dem Stimmzettel. Während der Abstimmung können die Teilnehmer mittels Präferenzwahl abstimmen, die es neben Zustimmung, Enthaltung und Ablehnung zusätzlich erlaubt Präferenzen zwischen den Initiativen anzugeben.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        Every initiative reaching a required quorum of supporters at the end of the verification phase is admitted for voting and appears on the voting ballot. During the voting phase every eligible participant may give a vote using a preferential voting system allowing to express individual preferences between the initiatives in addition to a yes/neutral/no vote.
      ]] }
    end
    
  end)
end)
ui.section(function()
  ui.sectionHead(function()
    ui.heading{ level = 1, content = _"Vote delegation" }
  end)
  ui.sectionRow(function()
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Delegationen ermöglichen eine dynamische Arbeitsteilung. Sie entsprechen einer Stimmrechtsvollmacht, können jederzeit geändert werden, sind weisungsfrei und übertragbar. Delegationen können für eine Gliederung, für einen Themenbereich der Gliederung oder für ein konkretes Thema erteilt werden. Konkretere Delegationen gehen allgemeineren Delegationen vor. Delegationen werden sowohl für den Diskurs (Phasen 1 bis 3) als auch für die Abstimmphase genutzt. Bei Aktivität eines Benutzers werden eventuell vorhandene Delegationen für die jeweilige Aktivität ausgesetzt.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        Delegations allow for a dynamic division of labor. A delegation is a proxy statement (voting power under a power of attorney), can be altered at any time, is not bound to directives and can be delegated onward. Delegations can be used for a whole organizational unit, for a subject area within an organizational unit, or for a specific issue. More specific delegations overrule more general delegations. Delegations are used in both the discourse (phase 1 to 3) and the voting phase. Any activity suspends existing delegations for the given activity.
      ]] }
    end
  end)
end)
ui.section(function()
  ui.sectionHead(function()
    ui.heading{ level = 1, content = _"Preference voting" }
  end)
  ui.sectionRow(function()
    if lang == "de" then
      ui.tag{ tag = "p", content = [[
        Im Falle mehrerer ähnlicher Vorschläge auf dem Stimmzettel gibt es keine Notwendigkeit einen dieser Vorschläge auszuwählen. Stattdessen kann für (bzw. gegen) beliebig viele konkurrierende Initiativen gestimmt werden und gleichzeitig eine Präferenzreihenfolge dieser Initiativen angegeben werden. Die Präferenzen bestimmen den Gewinner, falls am Ende mehr als eine Initiative die notwendige Mehrheit an Ja-Stimmen erreicht. Auf diese Weise wird niemand ermutigt für eine Initiative zu stimmen, nur um eine andere Initiative zu verhindern, und es wird niemand ermutigt gegen eine Initiative zu stimmen, nur um einer anderen Initiative eine Chance zu geben.
      ]] }
    else
      ui.tag{ tag = "p", content = [[
        If there are similar competing proposals on the ballot, there is no necessity to choose one of them. Instead, it is possible to vote for (and against) as many initiatives as one wants to while being able to express the individual preferences amongst those initiatives during voting phase. Those preferences will determine the winner if more than one initiative has reached the necessary majority of approvals at end of voting phase. That way, nobody is encouraged to vote in favor of one initiative just to outrank another one, and nobody is encouraged to vote against an initiative just to increase the chances for another initiative to win.
      ]] }
    end
  end)
end)
