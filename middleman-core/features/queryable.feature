Feature: Queryable Selector
  Scenario: Basic Selector Tests
    Then should initialize with an attribute and an operator
    Then should raise an exception if the operator is not supported
  Scenario: Using offset and limit
    Given the Server is running at "queryable-app"
    Then should limit the documents to the number specified
    Then should offset the documents by the number specified
    Then should support offset and limit at the same time
    Then should not freak out about an offset higher than the document count
  Scenario: Using where queries with an equal operator
    Given the Server is running at "queryable-app"
    Then should return the right documents
    Then should be chainable
    Then should not be confused by attributes not present in all documents
  Scenario: Using where queries with a complex operator
    Given the Server is running at "queryable-app"
    Then with a gt operator should return the right documents
    Then with a gte operator should return the right documents
    Then with an in operator should return the right documents
    Then with an lt operator should return the right documents
    Then with an lte operator should return the right documents
    Then with an include operator include should return the right documents
    Then with mixed operators should return the right documents
    Then using multiple constrains in one where should return the right documents
  Scenario: Sorting documents
    Given the Server is running at "queryable-app"
    Then should support ordering by attribute ascending
    Then should support ordering by attribute descending
    Then should order by attribute ascending by default
    Then should exclude documents that do not own the attribute
  Scenario: Passing queries around
    Given a simple 'where' query
    When I chain a where clause onto that query
    Then the original query should remain unchanged
