#!/usr/bin/env kscript

@file:DependsOn("org.slf4j:slf4j-simple:1.7.25")
@file:DependsOn("org.apache.velocity:velocity-engine-core:2.0")
@file:DependsOn("org.apache.commons:commons-csv:1.5")

import java.io.FileReader
import java.io.FileWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Properties
import org.apache.commons.csv.CSVFormat
import org.apache.commons.csv.CSVParser
import org.apache.velocity.app.Velocity
import org.apache.velocity.Template
import org.apache.velocity.VelocityContext

Velocity.init(Properties().apply {
})

val currentDate = SimpleDateFormat("dd/MM/yy")
	.format(Date())

val spells = FileReader("src/spells.csv").use { reader ->
	val format = CSVFormat.RFC4180.withFirstRecordAsHeader()
	CSVParser(reader, format).use { parser ->
		parser.map { record -> mapOf(
			"name"        to record.get("Name"),
			"type"        to record.get("Type"),
			"action"      to record.get("Action"),
			"range"       to record.get("Range"),
			"components"  to record.get("Components"),
			"duration"    to record.get("Duration"),
			"description" to record.get("Description")
		) }
	}
}

FileWriter("src/main.tex").use { writer ->
	Velocity.mergeTemplate(
			"src/main.tex.vm", "utf-8",
			VelocityContext(mapOf(
				"date"   to currentDate,
				"spells" to spells
			)),
			writer)
}

