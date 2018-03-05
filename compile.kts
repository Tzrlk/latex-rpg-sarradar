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

val log = LoggerFactory.getLogger("compile")

val csvformat = CSVFormat.RFC4180.withFirstRecordAsHeader()
fun <T> readcsv(file: String, mapper: (CSVRecord) -> T) = FileReader(file)
		.use { reader -> CSVParser(reader, csvformat)
				.use { parser -> parser.map(mapper) } }

log.info("Beginning spell data parsing.")
val spells = readcsv("src/spells.csv") { record -> mapOf(
	"name"        to record.get("Name"),
	"type"        to record.get("Type"),
	"action"      to record.get("Action"),
	"range"       to record.get("Range"),
	"components"  to record.get("Components"),
	"duration"    to record.get("Duration"),
	"description" to record.get("Description")
) }

log.info("Beginning discipline data parsing.")
val disciplines = readcsv("src/disciplines.csv") { record -> mapOf(
	"name"          to record.get("Name"),
	"category"      to record.get("Category"),
	"grade"         to record.get("Grade"),
	"prerequisites" to record.get("Prerequisites"),
	"description"   to record.get("Description")
) }

Velocity.init(Properties().apply {
})

val currentDate = SimpleDateFormat("dd/MM/yy")
		.format(Date())

log.info("Beginning template compilation.")
FileWriter("src/main.tex").use { writer ->
	Velocity.mergeTemplate(
			"src/main.tex.vm", "utf-8",
			VelocityContext(mapOf(
				"date"        to currentDate,
				"disciplines" to disciplines,
				"spells"      to spells
			)),
			writer)
}

