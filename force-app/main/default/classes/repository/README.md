# Repository classes
Repository classes should exist per business functionality. For example, there is a coach banking repository; anything pertaining to financial accounts and ANZx coaches in Get Help should belong here. We should also have a repository for identity (Azure, Forgerock etc.). Repositories can have multiple different services referenced within.

A repository class is an abstraction for a data source. Contains methods to retrieve, insert, update data for a specific data source. We should have all public consumer methods that interact with a given data source here, and all underlying classes and interactions are hidden to consumer and not to be interacted with. For example, a lightning web component must only make API calls via a Repository class, and not be aware of the underlying Service or Service Provider.

## Base class features
- Error handling/logging
    - If an underlying callout or interaction has an error, the repository base will create an application log, and throw the error.
