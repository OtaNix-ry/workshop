// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex

#import "@preview/touying:0.6.1": *

#let default-colors = (
  // Official NixOS branding guide palette (secondary blues + neutral support)
  // Afghani Blue: #4d6fb7, Argentinian Blue: #5fb8f2
  neutral-dark: rgb("#222222"),
  neutral-light: rgb("#555555"),
  neutral-lightest: rgb("#ffffff"),
  primary-dark: rgb("#4d6fb7"),
  primary-light: rgb("#a4d5f7"),
  secondary-light: rgb("#5fb8f2"),
  secondary-lighter: rgb("#e3f1fb"),
)

// Re-export the modern metropolis slide primitives.
#let slide = themes.metropolis.slide
#let title-slide = themes.metropolis.title-slide
#let focus-slide = themes.metropolis.focus-slide

#let otanix-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(
    setting: utils.fit-to-width.with(grow: false, 100%),
    depth: self.slide-level,
  ),
  footer: [],
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  footer-progress: true,
  ..args,
  body,
) = themes.metropolis.metropolis-theme(
  aspect-ratio: aspect-ratio,
  align: align,
  header: header,
  header-right: none,
  footer: footer,
  footer-right: footer-right,
  footer-progress: footer-progress,
  config-common(show-strong-with-alert: false),
  config-methods(
    alert: (self: none, it) => text(fill: default-colors.secondary-light, it),
  ),
  config-colors(
    // Built-in metropolis expects these names.
    primary: default-colors.secondary-light,
    primary-light: default-colors.secondary-lighter,
    secondary: default-colors.primary-dark,
    neutral-lightest: default-colors.neutral-lightest,
    neutral-dark: default-colors.neutral-light,
    neutral-darkest: default-colors.neutral-dark,
  ),
  ..args,
  body,
)

// iridis

#let need-regex-escape = (c) => {
	(c == "(") or (c == ")") or (c == "[") or (c == "]") or (c == "{") or (c == "}") or (c == "\\") or (c == ".") or (c == "*") or (c == "+") or (c == "?") or (c == "^") or (c == "$") or (c == "|") or (c == "-")
}

#let build-regex = (chars) => {
	chars.fold("", (acc, c) => {
		acc + (if need-regex-escape(c) { "\\" } else {""}) + c + "|"
	}).slice(0, -1)
}

#let copy-fields(equation, exclude:()) = {
	let fields = (:)
	for (k,f) in equation.fields() {
		if k not in exclude {
			fields.insert(k, f)
		}
	}
	fields
}

#let colorize-math(palette, equation, i : 0) = {
		if type(equation) != content {
		return equation
	}
	if equation.func() == math.equation {
		// this is a hack to mark the equation as colored so that we don't colorize it again
		if equation.body.has("children") and equation.body.children.at(0) == [#sym.space.hair] {
			equation
		} else {
			math.equation([#sym.space.hair] + colorize-math(palette, equation.body, i:i), block: equation.block)
		}
	} else if equation.func() == math.frac {
		math.frac(colorize-math(palette, equation.num, i:i), colorize-math(palette, equation.denom, i:i), ..copy-fields(equation, exclude:("num", "denom")))
	} else if equation.func() == math.accent {
			math.accent(colorize-math(palette, equation.base, i:i), equation.accent, size: equation.size)
	} else if equation.func() == math.attach {
			math.attach(
				colorize-math(palette, equation.base, i:i),
				..copy-fields(equation, exclude:("base",))
			)
	} else if equation.func() == math.cases {
		math.cases(..copy-fields(equation, exclude:("children")), ..equation.children.map(child => {
			colorize-math(palette, child, i:i)
		}))
	} else if equation.func() == math.vec {context {
			let color = text.fill
			show: text.with(fill: palette.at(calc.rem(i, palette.len())))
			math.vec(
				..copy-fields(equation, exclude:("children")),
				..equation.children.map(child => {
					show: text.with(fill: color)
					colorize-math(palette, child, i:i + 1)
				}),
			)		
		}} else if equation.func() == math.mat { context {
		let color = text.fill
		show: text.with(fill: palette.at(calc.rem(i, palette.len())))
		math.mat(
			..copy-fields(equation, exclude:("rows")),
			..equation.rows.map(row => row.map(cell => {
				show: text.with(fill: color)
				colorize-math(palette, cell, i:i + 1)
			})),
		)
		show: text.with(fill: color)
	} } else if equation.has("body") {
		equation.func()(colorize-math(palette, equation.body, i:i), ..copy-fields(equation, exclude:("body",)))
	} else if equation.has("children") { 
			let colorisation = equation.children.fold((i, ()), ((i, acc), child) => {
				if child == [(] {
					acc.push([
						#show: text.with(fill: palette.at(calc.rem(i, palette.len())))
						#equation.func()(([(],))])
					(i + 1, acc)
				} else if child == [)] {
					acc.push([
						#show: text.with(fill: palette.at(calc.rem(i - 1, palette.len())))
						#equation.func()(([)],))])
					(i - 1, acc)
				} else {
					acc.push(colorize-math(palette, child, i:i))
					(i, acc)
				}
		})
		equation.func()(..copy-fields(equation, exclude:("children")), colorisation.at(1))
	} else if equation.has("child") { // styles
		equation.func()(colorize-math(palette, equation.child, i:i), equation.styles)
	} else {
		equation
	}
}

#let colorize-code(counter : state("parenthesis", 0), opening-parenthesis : ("(","[","{"), closing-parenthesis : (")","]","}"), palette) = (body) =>  context {
	show regex(build-regex(opening-parenthesis)) :  body => context {
		show: text.with(fill: palette.at(calc.rem(counter.get(), palette.len()))) 
		body
		counter.update(n => n + 1)
	}

	show regex(build-regex(closing-parenthesis)) : body => context {
		counter.update(n => n - 1)
		text(fill: palette.at(calc.rem(counter.get() - 1, palette.len())), body)
	}
	body
}
