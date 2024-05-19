import glam/doc.{type Document}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

/// Convert a string of HTML in to the same document but using the Nakai HTML
/// syntax.
///
/// The resulting code is expected to be in a module with these imports:
///
/// ```gleam
/// import nakai/html
/// import nakai/attr.{Attr}
/// ```
///
pub type HtmlNode {
  Element(
    tag: String,
    attributes: List(#(String, String)),
    children: List(HtmlNode),
  )
  Comment(String)
  Text(String)
}

type DomElement {
  DomElement(String, List(#(String, String)), List(DomElement))
}

pub type Dom =
  List(#(String, List(#(String, String)), List(DomElement)))

type FastHtmlError

@external(erlang, "fast_html", "decode")
fn parse_to_dom(html: String) -> Result(Dom, FastHtmlError)

fn dom_element_to_element(dom: DomElement) -> HtmlNode {
  io.debug(dom)
  case dom {
    DomElement(_, _, []) -> {
      let DomElement(tag, attributes, _) = dom
      Element(tag, attributes, [])
    }
    DomElement(_, _, _) -> {
      let DomElement(tag, attributes, children) = dom
      let children = list.map(children, dom_element_to_element)
      Element(tag, attributes, children)
    }
  }
}

fn dom_to_records(dom: Dom) -> Result(HtmlNode, String) {
  io.debug(dom)
  case dom |> list.first {
    Ok(#("html", _, children)) -> {
      Ok(Element("html", [], list.map(children, dom_element_to_element)))
    }
    Ok(#("head", _, children)) -> {
      Ok(Element("head", [], list.map(children, dom_element_to_element)))
    }
    _ -> Error("No HTML tag found")
  }
}

pub fn convert(html: String) -> String {
  case
    html
    |> parse_to_dom
  {
    Ok(dom) -> {
      case
        dom
        |> dom_to_records
      {
        Ok(documents) -> {
          let children =
            documents
            |> strip_body_wrapper(html)
            |> print_children(StripWhitespace)

          case children {
            [] -> doc.empty
            [document] -> document
            _ -> wrap(children, "[", "]")
          }
          |> doc.to_string(80)
        }
        Error(err) -> {
          err
        }
      }
    }
    Error(_) -> {
      "Failed to parse HTML"
    }
  }
}

type WhitespaceMode {
  PreserveWhitespace
  StripWhitespace
}

fn strip_body_wrapper(html: HtmlNode, source: String) -> List(HtmlNode) {
  let full_page = string.contains(source, "<head>")
  case html, full_page {
    Element("HTML", [], [Element("HEAD", [], []), Element("BODY", [], nodes)]),
      False
    -> nodes
    _, _ -> [html]
  }
}

fn print_text(t: String) -> Document {
  doc.from_string("html.Text(" <> print_string(t) <> ")")
}

fn print_string(t: String) -> String {
  "\"" <> string.replace(t, "\"", "\\\"") <> "\""
}

fn print_element(
  tag: String,
  attributes: List(#(String, String)),
  children: List(HtmlNode),
  ws: WhitespaceMode,
) -> Document {
  let tag = string.lowercase(tag)
  let attributes =
    list.map(attributes, print_attribute)
    |> wrap("[", "]")

  case tag {
    "area"
    | "base"
    | "br"
    | "col"
    | "embed"
    | "hr"
    | "img"
    | "input"
    | "link"
    | "meta"
    | "param"
    | "source"
    | "track"
    | "wbr" -> {
      doc.from_string("html." <> tag <> "(")
      |> doc.append(attributes)
      |> doc.append(doc.from_string(")"))
    }

    "a"
    | "abbr"
    | "address"
    | "article"
    | "aside"
    | "audio"
    | "b"
    | "bdi"
    | "bdo"
    | "blockquote"
    | "button"
    | "canvas"
    | "caption"
    | "cite"
    | "code"
    | "colgroup"
    | "data"
    | "datalist"
    | "dd"
    | "del"
    | "details"
    | "dfn"
    | "dialog"
    | "div"
    | "dl"
    | "dt"
    | "em"
    | "fieldset"
    | "figcaption"
    | "figure"
    | "footer"
    | "form"
    | "h1"
    | "h2"
    | "h3"
    | "h4"
    | "h5"
    | "h6"
    | "header"
    | "hgroup"
    | "i"
    | "iframe"
    | "ins"
    | "kbd"
    | "label"
    | "legend"
    | "li"
    | "main"
    | "map"
    | "mark"
    | "math"
    | "menu"
    | "meter"
    | "nav"
    | "noscript"
    | "object"
    | "ol"
    | "optgroup"
    | "option"
    | "output"
    | "p"
    | "picture"
    | "portal"
    | "progress"
    | "q"
    | "rp"
    | "rt"
    | "ruby"
    | "s"
    | "samp"
    | "search"
    | "section"
    | "select"
    | "slot"
    | "small"
    | "span"
    | "strong"
    | "style"
    | "sub"
    | "summary"
    | "sup"
    | "svg"
    | "table"
    | "tbody"
    | "td"
    | "template"
    | "text"
    | "tfoot"
    | "th"
    | "thead"
    | "time"
    | "title"
    | "tr"
    | "u"
    | "ul"
    | "var"
    | "video" -> {
      let children = wrap(print_children(children, ws), "[", "]")
      doc.from_string("html." <> tag)
      |> doc.append(wrap([attributes, children], "(", ")"))
    }

    "head" | "body" | "html" -> {
      // | "script" Skip script tags as they are experimental 
      let children = wrap(print_children(children, ws), "[", "]")
      doc.from_string("html." <> tag |> capitalize)
      |> doc.append(wrap([attributes, children], "(", ")"))
    }

    "pre" -> {
      let children =
        wrap(print_children(children, PreserveWhitespace), "[", "]")
      doc.from_string("html." <> tag)
      |> doc.append(wrap([attributes, children], "(", ")"))
    }

    "textarea" -> {
      let content = doc.from_string(print_string(get_text_content(children)))
      doc.from_string("html." <> tag)
      |> doc.append(wrap([attributes, content], "(", ")"))
    }

    _ -> {
      let children = wrap(print_children(children, ws), "[", "]")
      let tag = doc.from_string(print_string(tag))
      doc.from_string("html.Element")
      |> doc.append(wrap([tag, attributes, children], "(", ")"))
    }
  }
}

fn get_text_content(nodes: List(HtmlNode)) -> String {
  list.filter_map(nodes, fn(node) {
    case node {
      Text(t) -> Ok(t)
      _ -> Error(Nil)
    }
  })
  |> string.concat
}

fn print_children(
  children: List(HtmlNode),
  ws: WhitespaceMode,
) -> List(Document) {
  list.filter_map(children, fn(node) {
    case node {
      Element(a, b, c) -> Ok(print_element(a, b, c, ws))
      Comment(_) -> Error(Nil)
      Text(t) if ws == StripWhitespace -> strip_whitespace(t)
      Text(t) -> Ok(print_text(t))
    }
  })
}

fn strip_whitespace(t: String) {
  case string.trim_left(t) {
    "" -> Error(Nil)
    t -> Ok(print_text(t))
  }
}

fn print_attribute(attribute: #(String, String)) -> Document {
  case attribute.0 {
    "accept"
    | "action"
    | "alt"
    | "autocapitalize"
    | "autocomplete"
    | "capture"
    | "charset"
    | "cite"
    | "class"
    | "content"
    | "enctype"
    | "for"
    | "formaction"
    | "height"
    | "href"
    | "id"
    | "integrity"
    | "lang"
    | "maxlength"
    | "method"
    | "minlength"
    | "name"
    | "placeholder"
    | "property"
    | "rel"
    | "role"
    | "src"
    | "style"
    | "tabindex"
    | "target"
    | "title"
    | "value"
    | "width" -> {
      doc.from_string(
        "attr." <> attribute.0 <> "(" <> print_string(attribute.1) <> ")",
      )
    }

    "async"
    | "autofocus"
    | "autoplay"
    | "checked"
    | "contenteditable"
    | "crossorigin"
    | "controls"
    | "defer"
    | "disabled"
    | "draggable"
    | "hidden"
    | "loop"
    | "multiple"
    | "muted"
    | "novalidate"
    | "open"
    | "preload"
    | "readonly"
    | "required"
    | "selected" -> {
      doc.from_string("attr." <> attribute.0 <> "()")
    }

    // Kebab case attributes
    "accept-charset"
    | "aria-checked"
    | "aria-current"
    | "aria-label"
    | "aria-labelledby"
    | "aria-placeholder"
    | "aria-readonly"
    | "aria-required"
    | "http-equiv" -> {
      doc.from_string(
        "attr."
        <> attribute.0 |> string.replace("-", "_")
        <> "("
        <> print_string(attribute.1)
        <> ")",
      )
    }

    "aria-disabled" | "aria-hidden" | "aria-invalid" -> {
      doc.from_string(
        "attr." <> attribute.0 |> string.replace("-", "_") <> "()",
      )
    }

    // Type is a reserved word so we need to use attr.type_ instead
    "type" -> doc.from_string("attr.type_(" <> print_string(attribute.1) <> ")")

    // Data attribute takes 2 elements, we need a special case for it
    // "data" -> todo
    // Escape hatch for unknown attributes i.e. htmx or similar
    _ -> {
      let children = [
        doc.from_string(print_string(attribute.0)),
        doc.from_string(print_string(attribute.1)),
      ]
      doc.from_string("attr.Attr")
      |> doc.append(wrap(children, "(", ")"))
    }
  }
}

fn wrap(items: List(Document), open: String, close: String) -> Document {
  let comma = doc.concat([doc.from_string(","), doc.space])
  let open = doc.concat([doc.from_string(open), doc.soft_break])
  let trailing_comma = doc.break("", ",")
  let close = doc.concat([trailing_comma, doc.from_string(close)])

  items
  |> doc.join(with: comma)
  |> doc.prepend(open)
  |> doc.nest(by: 2)
  |> doc.append(close)
  |> doc.group
}

fn capitalize(s: String) -> String {
  case s {
    "" -> ""
    v ->
      string.uppercase(v |> string.slice(0, 1))
      <> v |> string.slice(1, string.length(s))
  }
}
