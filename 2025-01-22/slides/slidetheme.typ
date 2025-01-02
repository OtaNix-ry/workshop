// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex

#import "@preview/touying:0.4.2": *

// Consider using: NOTE doesn't work?
// #set text(font: "Fira Sans", weight: "light", size: 20pt)
// #show math.equation: set text(font: "Fira Math")
// #set strong(delta: 100)
// #set par(justify: true)

#let _saved-align = align

#let default-colors = (
    neutral-dark: rgb("#fafafa"),
    neutral-lightest: rgb("#232323"),
    primary-dark: rgb("#57a8ed"),
    primary-light: rgb("#27385d"),
    secondary-light: rgb("#ff8657"),
    secondary-lighter: rgb("#27385d"), // same as primary-light?
)

#let slide(
  self: none,
  title: auto,
  footer: auto,
  align: horizon,
  ..args,
) = {
  self.page-args += (
    fill: self.colors.neutral-lightest,
  )
  if title != auto {
    self.m-title = title
  }
  if footer != auto {
    self.m-footer = footer
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    title: if title == auto { self.m-title = title } else { title },
    setting: body => {
      show: _saved-align.with(align)
      set text(fill: self.colors.neutral-dark)
      show: args.named().at("setting", default: body => body)
      body
    },
    ..args.pos(),
  )
}

#let title-slide(
  self: none,
  extra: none,
  ..args,
) = {
  self.page-args += (
    fill: self.colors.neutral-lightest,
  )
  self = utils.empty-page(self)
  let info = self.info + args.named()
  let content = {
    set text(fill: self.colors.neutral-dark)
    set align(horizon)
    block(width: 100%, inset: 2em, {
      text(size: 1.3em, text(weight: "medium", info.title))
      if info.subtitle != none {
        linebreak()
        text(size: 0.9em, info.subtitle)
      }
      line(length: 100%, stroke: .05em + self.colors.secondary-light)
      set text(size: .8em)
      if info.author != none {
        block(spacing: 1em, info.author)
      }
      if info.date != none {
        block(spacing: 1em, utils.info-date(self))
      }
      set text(size: .8em)
      if info.institution != none {
        block(spacing: 1em, info.institution)
      }
      if extra != none {
        block(spacing: 1em, extra)
      }
    })
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let new-section-slide(self: none, short-title: auto, title) = {
  self = utils.empty-page(self)
  let content = {
    set align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em)
    states.current-section-with-numbering(self)
    block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.m-progress-bar))
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: title, short-title: short-title), content)
}

#let focus-slide(self: none, background-img: none, body) = {
  self = utils.empty-page(self)
  self.page-args += (
    fill: self.colors.primary-light,
    margin: 2em,
    ..(if background-img != none { (background: {
        // set image(fit: "stretch", width: 100%, height: 100%)
        background-img
      })
    }),
  )
  set text(fill: self.colors.neutral-dark, size: 1.5em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let custom-slide(self: none, page-args: none, ..args) = {
  self = utils.empty-page(self)
  self.page-args += page-args
  slide(self: self, ..args.named(), ..args.pos())
}

#let slides(self: none, title-slide: true, outline-slide: false, outline-title: [Table of contents], slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  if outline-slide {
    (self.methods.slide)(self: self, title: outline-title, (self.methods.touying-outline)())
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  header: states.current-section-with-numbering,
  footer: [],
  footer-right: states.slide-counter.display() + " / " + states.last-slide-number,
  footer-progress: true,
  ..args,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    ..default-colors,
  )
  // save the variables for later use
  self.m-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      components.cell(fill: self.colors.secondary-light),
      components.cell(fill: self.colors.secondary-lighter)
    )
  })
  self.m-footer-progress = footer-progress
  self.m-title = header
  self.m-footer = footer
  self.m-footer-right = footer-right
  // set page
  let header(self) = {
    set align(top)
    if self.m-title != none {
      show: components.cell.with(fill: rgb("#00000000"), inset: 1em)
      set align(horizon)
      set text(fill: self.colors.secondary-light, size: 1.2em)
      utils.fit-to-width(grow: false, 100%, text(font: "Fira Sans", weight: "bold", utils.call-or-display(self, self.m-title)))
    } else { [] }
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.65em)
    pad(.5em, {
      text(fill: self.colors.neutral-dark.lighten(40%), utils.call-or-display(self, self.m-footer))
      h(1fr)
      text(fill: self.colors.neutral-dark, utils.call-or-display(self, self.m-footer-right))
    })
    if self.m-footer-progress {
      place(bottom, block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.m-progress-bar)))
    }
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    header-ascent: 30%,
    footer-descent: 30%,
    margin: (top: 3em, bottom: 1.5em, x: 2em),
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.custom-slide = custom-slide
  self.methods.slides = slides
  self.methods.touying-outline = (self: none, enum-args: (:), ..args) => {
    states.touying-outline(self: self, enum-args: (tight: false,) + enum-args, ..args)
  }
  self.methods.alert = (self: none, it) => text(fill: self.colors.secondary-light, it)
  self
}

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