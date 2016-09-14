I have selected AsciiBinder because it:

* is solely an AsciiDoc processor. This will force us to the new format
   without delay.
* it has been adopted by several [open
   source](https://github.com/openshift/openshift-docs)
   [projects](https://github.com/ManageIQ/manageiq_docs)
   communities. Therefore, it is going to both have longevity and a lot of
   people looking for bugs and suggesting and implementing new features.
* it has a [healthy number of
   contributors](https://github.com/redhataccess/ascii_binder/graphs/contributors).
* it is a pure AsciiDoc toolchain with no conversions or other processing.

There are a few concerns:

* AsciiBinder is solely an AsciiDoc toolchain, so we have to convert in
   order to publish.  DocBook to AsciiDoc is a strangely difficult process
   that has not been fully automated and tooled.  However, it is also a
   one-time process and one which we can minimize by making reasonable
   decisions about what should be converted and by not converting old
   versions of documentation.
* Asciibinder is built on a single repository model.  This is partly
   because the current users all use this model.  I have written a
   simple builder script that will massage our multiple repositories into
   something that AsciiBinder can handle.  The upstream is also [willing
   to think about](https://github.com/redhataccess/ascii_binder/issues/54)
   multiple repository solutions, but isn't set on one yet.
* Asciibinder doesn't understand translations.  This is partly because
   none of the current users do not translate their documentation.
   I suspect this is also because translation of AsciiDoc is a weirdly
   undocumented problem with only one solution that I have been able
   to find.  More on that later.  Regardless of how the translations
   are completed, building them is just an extension of the multiple
   version problem above and is therefore solved with my builder script.

left to do
* po4a
* i18n weigh in
* semantic markup decisions
* conversions
* css

extensions
* search
* CI/CD


--------------------------------------------------------------------------------

# Where Do I Think We are With the Fedora Docs Reboot?

Sample builds and technical notes are on
[fedorapeop.org](https://fedorapeople.org/~bex/docs.html)

I believe there are three areas of focus, content, conversion,
and publishing. Because content should *always* drive documentation
conversations, let's start there:

## Content

1. AsciiDoc Style Guide

   None has been adopted.

   **Suggested Action Plan**: Review [OpenShift's Style
   Guide](https://github.com/openshift/openshift-docs/blob/master/contributing_to_docs/doc_guidelines.adoc)
   and adapt it for Fedora.

1. Topic Writing Guidance

   None has been adopted.

   **Suggested Action Plan**: Define Topic and put together some examples.

   The [Beginners Guide](https://pagure.io/docs-beginner)
   is slowly being replaced by the [Documentation
   Guide](https://pagure.io/documentation-guide/tree/new-workflow).
   However, neither guide has any significant content about any style
   of writing or formatting (see above). There is also not a lot of
   explanation about why we made our decisions. Today we can only write
   about why we have chosen to go with AsciiDoc and about how to think
   about your writing with regards to language translations. Tooling
   and process will have to come later.

   **Suggested Action Plan**: Develop content for:

       * Writing for language translation
       * An overview of the language translation process
       * Why did we choose AsciiDoc
       * Writing style, including voice, etc.

1. What Content Should be Converted

   No decisions.

   **Suggested Action Plan**: Decide if any content can be deprecated
   for replacement with new writing. I suggest we not blanket republish
   and get *very* choosy.

## Conversion

Some conversion issues need to wait until the publishing tooling is
resolved, however not all of it needs to wait.

1. DocBook to AsciiDoc Conversion

   There is no perfect or accepted best solution. Every tool has
   challenges and problems. The process used by other groups that have
   done a format conversion tends to be one of two processes:

   1. "Burn it down" - Throw away everything and rewrite it from scratch.

      This is not practical for the entire documentation set, however
      it could be used to reduce the amount of "cruft."  This could also
      effectively be used to sunset books that have not been republished
      or updated in a long time.

   1. "Convert, Polish, Review" - use an automated tool; clean up the
      output; get it reviewed by several folks.

      Talking with folks at Red Hat who have done
      similar conversions, the current best choice tool is
      [DocBookRx](https://github.com/asciidoctor/docbookrx). It is
      not perfect. However, it will at least warn on unconverted tags.

      After the automated conversion, everything else is review and
      fixes. It is recommended that you use `elinks` to create two text
      files from the html output of the pre-conversion document and the
      post-conversion document. Then you can use `meld` to highlight a
      lot of the formatting differences. YMMV.

   **Suggested Action Plan**: Develop a conversion script of actions to
   take and automation where possible based on a larger heavily edited
   book, such as the Installation Guide.

1. Migration to pagure.io

   Complete

1. Breaking Books in to Collections of Documents (Topics)

   Not started

   **Suggested Action Plan**: Develop a model based on a smaller book.
   Use this experience to document "best practices."

## Publishing

1. Language Translations (Getting them done)

   There is no standard process for working with AsciiDoc and Zanata.
   Today, Zanata doesn't support AsciiDoc as an input format. The only
   real options appear to be:

   1. Stop publishing language translations until the Zanata team has
      a solution.

      This is not really optimal, but if a solution is imminent may not
      be devasting.

   1. Find a tool to generate `.pot` files from AsciiDoc and to apply
      `.po` files to AsciiDoc.

      So far, the best tool appears to be
      [po4a](https://po4a.alioth.debian.org/). While po4a is packaged for
      Fedora, it is in mainaintenance mode and not receiving significant
      updates. It will need some level of development effort to get it
      working acceptably.

   1. Perform language translations using transformations.

      This would involve converting AsciiDoc to a format, such as DocBook,
      that has a known `.pot/.po` toolchain. This could pose a real
      challenge to publishing depending on the tooling as not all tools
      can support all formats. I also feel like relying on multi-level
      automated conversions is ultimately fragile.

   1. Use pintail

      Work is being undertaken to get pintail to do `.pot/.po`
      transformations. If pintail remains the publication tool (see
      below), this would solve the problem. The status of this is
      unknown.

   **Suggested Action Plan**: Actively engage the Fedora Translation
   and Zanata teams. Determine if pintail is going to be chosen.
   Give serious consideration to po4a if nothing else appears.

1. Publishing Tools

   This tool(chain) needs to fulfill the following requirements:

   * Transform markup into HTML
   * Assemble a multi-version site
   * Assemble a multi-language site
   * Support being packaged in Fedora
   * Be able to be automated
   * Provide a relatively easy set up experience for writers to test with
   * Interface with Zanata (see above)
   * Support Theming
   * Able to integrate with a search solution

   ### pintail

   The Docs FAD selected
   [pintail](https://github.com/projectmallard/pintail). Pintail's answer
   to the requirements is:

   * Transform markup into HTML

     This is done by converting DocBook and AsciiDoc into an intermediate
     XML format (mallard?). This is then converted to HTML.

   * Assemble a multi-version site

     Multi-version support is done by specifying different branches of
     repos to be built at the same time.
    
   * Assemble a multi-language site

     Multi-lingual support is currently an unknown.

   * Support being packaged in Fedora

     Packages are working their way through the review process.

   * Be able to be automated

     This should be able to be done as there are no required manual steps
     that do not have a reasonably scriptable algorithm.

   * Provide a relatively easy set up experience for writers to test with

     Setup directions need to be improved, however it is able to be run
     from both a container and via a direct install.

   * Interface with Zanata (see above)

     This is an unknown. Presumably the intermediate XML format has easy
     `.pot/.po` processing.

   * Support Theming

     Pintail requires a combination of CSS and XSLT in order to theme.
     No one from the Fedora Design team has signed on to do the theming
     and it appears that the existing Fedora CSS theming is not easily
     reusable.

   * Able to integrate with a search solution

     Work is being done on integration with elastic-search.

   ### AsciiBinder

   I have started a "skunkworks" project to use
   [AsciiBinder](http://www.asciibinder.org/) instead. Here is how I
   think AsciiBinder answers the requirements. Following that is my
   feelings about why it is the better choice.

   * Transform markup into HTML

     AsciiBinder uses [AsciiDoctor](http://asciidoctor.org/) to convert 
     AsciiDoc to HTML.

   * Assemble a multi-version site

     Multi-version support is done by specifying version to branch
     mappings. This is a defined objective and model of AsciiBinder and
     is natively supported.

   * Assemble a multi-language site

     Multi-lingual support is currently an unknown.

   * Support being packaged in Fedora

     AsciiBinder is not currently packaged. Dependencies all appear to
     be packaged.

   * Be able to be automated

     This should be able to be done as there are no required manual steps
     that do not have a reasonably scriptable algorithm.

   * Provide a relatively easy set up experience for writers to test with

     Setup directions need to be improved, however it is able to be run
     from both a container and via a direct install.

   * Interface with Zanata (see above)

     This is an unknown. The primary challenge is the AsciiDoc to `.pot`
     transformation and the subsequent `.po` processing. po4a has
     possibilities.

   * Support Theming

     AsciiBinder supports CSS only theming and should be able to be
     handled by the Fedora Design Team.

   * Able to integrate with a search solution

     This is an unknown, however it generates a static site so many
     standard solutions should work.

   I feel like AsciiBinder is the superior solution for the following
   reasons:

   1. Adoption by other Projects

      AsciiBinder has been adopted by OpenShift and ManageIQ. This leads
      me to believe there will continue to be innovation, maintenance
      and a migraton path if the tool is ever deprecated. As far as I
      can tell there is no other project that has implemented pintail.
      Gnome is either considering it still or has decided to begin the
      implementation process. Gnome uses Mallard for their documentation
      which means the AsciiDoc and DocBook imports and maintenance are
      only for Fedora.

   1. Contributor Count

      AsciiBinder has 13 contributors. 5 have made code contributions
      and 1 has only contributed to the container.

      Pintail has 4 contributors as of 1 September. Only one contributor
      has made code contributions, from what I can tell.

      Both projects are primarily supported by Red Hat contributors.

   1. Coding Language

      AsciiBinder is Ruby. Pintail relies on Python and XSLT. XSLT is
      not something a lot of people have strong skills with.

   1. Theming

      AsciiBinder is pure CSS Theming. Pintail requires XSLT to be
      written.

   1. AsciiDoc only support

      AscciBinder will force us to quickly move documents into AsciiDoc.
      I am concerned that if we are not pushed externally to do this
      we will never quite finish it. I think DocBook support in our
      new publishing tool is setting us up for never quite finishing
      the AsciiDoc conversion. Other projects that have moved away
      from DocBook to AsciiDoc have reported a sizable increase in
      contributors. We need this.


   It isn't all rainbows and unicorns though, there are a few challenges:

   1. AsciiDoc Language Translation Support

      There is no standardized way of intefacing AsciiDoc with Zanata.
      This is a problem that other communities need to solve so a solution
      should show up soon from the gestalt. There are solutions, like
      po4a, that appear to be "almost there."

      My experiments with po4a have been positive, but there is some
      cleanup needed. I don't have enough Zanata access to run a full
      roundtrip test.

   1. Single Repo Mindset in AsciiBinder

      AsciiBinder is written from a multi-site multi-version
      but single repository mindset. There is an open
      [issue](https://github.com/redhataccess/ascii_binder/issues/54)
      discussing what to do with multi-repository documentation sets.
      In the interim, I have developed a scriptable method of bilding
      out a processable collection from multiple repositories. It is
      a loop of about 4 shell commands that can be scripted.

   1. Language Translation Support in AsciiBinder

      AsciiBinder has not considered the language translation question
      at all, as far as I can tell. I believe a method similar to the
      multi-repo solution above can be used. I have not tested this
      because I haven't roundtripped a translation yet.

   1. AsciiDoc only support

      Because AsciiBinder only supports AsciiDoc, we need to relatively
      quickly get any DocBook converted. We have no guarantee
      contributors will invest in this effort.