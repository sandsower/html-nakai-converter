import gleeunit
import gleeunit/should
import html_nakai_converter

pub fn main() {
  gleeunit.main()
}

pub fn empty_test() {
  ""
  |> html_nakai_converter.convert
  |> should.equal("")
}

pub fn h1_test() {
  "<h1></h1>"
  |> html_nakai_converter.convert
  |> should.equal("html.h1([], [])")
}

// pub fn h1_2_test() {
//   "<h1></h1><h1></h1>"
//   |> html_nakai_converter.convert
//   |> should.equal("[html.h1([], []), html.h1([], [])]")
// }

// pub fn h1_3_test() {
//   "<h1></h1><h1></h1><h1></h1><h1></h1><h1></h1>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "[
//   html.h1([], []),
//   html.h1([], []),
//   html.h1([], []),
//   html.h1([], []),
//   html.h1([], []),
// ]",
//   )
// }

// pub fn h1_4_test() {
//   "<h1>Jello, Hoe!</h1>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.h1([], [html.Text(\"Jello, Hoe!\")])")
// }

// pub fn text_test() {
//   "Hello, Joe!"
//   |> html_nakai_converter.convert
//   |> should.equal("html.Text(\"Hello, Joe!\")")
// }

// pub fn element_nakai_does_not_have_a_helper_for_test() {
//   "<marquee>I will die mad that this element was removed</marquee>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.Element(\n  \"marquee\",\n  [],\n  [html.Text(\"I will die mad that this element was removed\")],\n)",
//   )
// }

// pub fn attribute_test() {
//   "<a href=\"https://gleam.run/\">The best site</a>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.a([attr.href(\"https://gleam.run/\")], [html.Text(\"The best site\")])",
//   )
// }

// pub fn other_attribute_test() {
//   "<a data-thing=\"1\">The best site</a>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.a([attr.Attr(\"data-thing\", \"1\")], [html.Text(\"The best site\")])",
//   )
// }

// pub fn no_value_attribute_test() {
//   "<p type=good></p>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.p([attr.type_(\"good\")], [])")
// }

// pub fn void_br_test() {
//   "<br>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.br([])")
// }

// pub fn void_br_with_attrs_test() {
//   "<br class=good>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.br([attr.class(\"good\")])")
// }

// pub fn its_already_a_page_test() {
//   "<html><head><title>Hi</title></head><body>Yo</body></html>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.Html(\n  [],\n  [\n    html.Head([], [html.title([], [html.Text(\"Hi\")])]),\n    html.Body([], [html.Text(\"Yo\")]),\n  ],\n)",
//   )
// }

// pub fn its_already_a_page_1_test() {
//   "<html><head></head><body>Yo</body></html>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.Html([], [html.Head([], []), html.Body([], [html.Text(\"Yo\")])])",
//   )
// }

// pub fn text_with_a_quote_in_it_test() {
//   "Here is a quote \" "
//   |> html_nakai_converter.convert
//   |> should.equal("html.Text(\"Here is a quote \\\" \")")
// }

// pub fn non_string_attribute_test() {
//   "<br random>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.br([attr.Attr(\"random\", \"\")])")
// }

// pub fn bool_attribute_test() {
//   "<br required>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.br([attr.required()])")
// }

// pub fn int_attribute_test() {
//   "<br width=\"400\">"
//   |> html_nakai_converter.convert
//   |> should.equal("html.br([attr.width(\"400\")])")
// }

// pub fn full_page_test() {
//   let code =
//     "
// <!doctype html>
// <html>
//   <head>
//     <title>Hello!</title>
//   </head>
//   <body>
//     <h1>Goodbye!</h1>
//   </body>
// </html>
//   "
//     |> html_nakai_converter.convert

//   code
//   |> should.equal(
//     "html.Html(
//   [],
//   [
//     html.Head([], [html.title([], [html.Text(\"Hello!\")])]),
//     html.Body([], [html.h1([], [html.Text(\"Goodbye!\")])]),
//   ],
// )",
//   )
// }

// pub fn comment_test() {
//   "<h1><!-- This is a comment --></h1>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.h1([], [])")
// }

// pub fn trailing_whitespace_test() {
//   "<h1>Hello </h1><h2>world</h2>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "[html.h1([], [html.Text(\"Hello \")]), html.h2([], [html.Text(\"world\")])]",
//   )
// }

// pub fn textarea_whitespace_test() {
//   "<div>
//   <textarea>
//     Hello!
//   </textarea>
// </div>"
//   |> html_nakai_converter.convert
//   |> should.equal("html.div([], [html.textarea([], \"    Hello!\n  \")])")
// }

// pub fn pre_whitespace_test() {
//   "<pre>
//     <code>
//       Hello!
//     </code>
//   </pre>"
//   |> html_nakai_converter.convert
//   |> should.equal(
//     "html.pre(
//   [],
//   [\n    html.Text(\"    \"),\n    html.code([], [html.Text(\"\n      Hello!\n    \")]),\n    html.Text(\"\n  \"),\n  ],
// )",
//   )
// }
