Contributing
============

Pull Request Checklist
------------------------
1. Make sure your change does not break idempotency tests. See [Testing](#Testing)
(or let CI run the tests for you if you are certain it is idempotent.)
If a task cannot be made idempotent, add the tag [molecule-idempotence-notest](https://github.com/ansible-community/molecule/issues/816#issuecomment-573319053).
2. Unless a change is small or doesn't affect users, create an issue on
[github](https://github.com/ansible/galaxy-operator/issues/new).
3. Push your branch to your fork and open a [Pull request across forks.](https://help.github.com/articles/creating-a-pull-request-from-a-fork/)
4. Add GitHub labels as appropriate.

Docs Testing
------------

Cross-platform:
```
pip install mkdocs pymdown-extensions mkdocs-material mike mkdocs-git-revision-date-plugin
```

Then:
```
mkdocs serve
```
Click the link it outputs. As you save changes to files modified in your editor,
the browser will automatically show the new content.
