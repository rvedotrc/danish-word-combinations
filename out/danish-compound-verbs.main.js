(() => {
  let combinations = null;
  window.combinations = data => (combinations = data);

  let definitions = null;
  window.definitions = data => (definitions = data);

  window.render = () => {
    const prefixes = Object.keys(combinations).sort();

    const rootsMap = {};
    Object.values(combinations).forEach(t =>
      Object.keys(t).forEach(root => (rootsMap[root] = true))
    );
    const roots = Object.keys(rootsMap).sort();

    const table = document.createElement("table");
    document.getElementById("container").appendChild(table);

    const head1 = document.createElement("tr");
    table.appendChild(head1);
    const head2 = document.createElement("tr");
    table.appendChild(head2);

    head1.appendChild(document.createElement("th"));
    head1.appendChild(document.createElement("th"));
    head2.appendChild(document.createElement("th"));
    head2.appendChild(document.createElement("th"));

    const thContaining = (t, lang, klass) => {
      const th = document.createElement("th");
      th.setAttribute("lang", lang);
      th.setAttribute("class", klass);
      th.appendChild(document.createTextNode(t));
      return th;
    };

    prefixes.forEach(prefix => {
      head1.appendChild(
        thContaining(definitions[prefix] || "?", "en", "prefix")
      );
      head2.appendChild(thContaining(prefix, "da", "prefix"));
    });

    roots.forEach(root => {
      const row = document.createElement("tr");
      table.appendChild(row);

      row.appendChild(thContaining(definitions[root] || "?", "en", "root"));
      row.appendChild(thContaining(root, "da", "root"));

      prefixes.forEach(prefix => {
        const td = document.createElement("td");
        row.appendChild(td);

        if (combinations[prefix][root]) {
          td.setAttribute("class", "combination");

          const span1 = document.createElement("span");
          span1.setAttribute("class", "formula-prefix");
          span1.appendChild(
            document.createTextNode(definitions[prefix] || prefix)
          );

          const span2 = document.createElement("span");
          span2.setAttribute("class", "formula-root");

          if (definitions[root]) {
            span2.setAttribute("lang", "en");
            span2.appendChild(document.createTextNode(definitions[root]));
          } else {
            span2.setAttribute("lang", "da");
            span2.appendChild(document.createTextNode(root));
          }

          const word = prefix + root;
          const span3 = document.createElement("span");
          span3.setAttribute("class", "formula-result");
          span3.appendChild(document.createTextNode(definitions[word] || "?"));

          td.appendChild(span1);
          td.appendChild(span2);
          td.appendChild(span3);
        }
      });
    });
  };
})();
