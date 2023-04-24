# tabbed-forum-page
Custom forum page for Khoros community platform with tabbed filters.

Setting the Custom Page
-----------------------

This is a custom page that can be set in admin. Go to "Board Admin" for the forum you want to set. Then select Content -> Custom Pages and set the Forum Page to **ForumPage.TabbedFilters**.

Custom Components
-----------------

*   **custom-tabbed-message-list** - The primary custom component added to the custom page above.
*   **custom-tabbed-paging** - Adds the out of the box paging to the page only if the "all" tab is selected because this also shows the OOB message list which uses it.
*   **message-list-override** - Overrides the OOB message list to show only if the "all" tab is selected or to show on the default forum page.
