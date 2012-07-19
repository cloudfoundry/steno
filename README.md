# Steno
Steno is a lightweight, modular logging library written specifically to support
Cloud Foundry.

## Concepts

Steno is composed of three main classes: loggers, sinks, and formatters. Loggers
are the main entry point for Steno. They consume user input, create structured
records, and forward said records to the configured sinks. Sinks are the
ultimate destination for log records. They transform a structured record into
a string via a formatter and then typically write the transformed string to
another transport.

## Getting started
    config = Steno::Config.new(
      :sinks   => [Steno::Sink::IO.new(STDOUT)],
      :codec   => Steno::Codec::Json.new,
      :context => Steno::Context::ThreadLocal.new)

    Steno.init(config)

    logger = Steno.logger("test")

    logger.info("Hello world!")

## File a Bug

To file a bug against Cloud Foundry Open Source and its components, sign up and use our
bug tracking system: [http://cloudfoundry.atlassian.net](http://cloudfoundry.atlassian.net)
