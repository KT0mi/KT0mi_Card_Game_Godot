class_name CardText extends RefCounted

#Helper for formatting dynamic per-instance injected text in displayed card text
#Uses BBcode for rich text labels

const DYNAMIC_COLOR := "#ffcc4d"  ## placeholder -- swap for your palette

static func dynamic(value) -> String:
	return "[b][color=%s]%s[/color][/b]" % [DYNAMIC_COLOR, str(value)]
