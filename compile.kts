#!/usr/bin/env kscript

@file:DependsOn("org.apache.velocity:velocity-engine-core:2.0")

import org.apache.velocity.app.VelocityEngine
import org.apache.velocity.Template
import org.apache.velocity.VelocityContext

val engine = VelocityEngine().apply {
	init()
}

val template = engine.getTemplate("src/main.tex.vm")

val context = VelocityContext().apply {
	put("date", "November 2017")
}

FileWriter("src/main.tex").use {
	template.merge(context, it)
}

