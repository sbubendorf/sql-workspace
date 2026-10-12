drop type circle;

drop type shape;

-- Parent object type
CREATE OR REPLACE TYPE Shape AS OBJECT (
   name VARCHAR2(50),
   MEMBER FUNCTION area RETURN NUMBER
) not final;
/

-- Parent type body
CREATE OR REPLACE TYPE BODY Shape AS
   MEMBER FUNCTION area RETURN NUMBER IS
   BEGIN
      RETURN 0; -- Default implementation
   END;
END;
/

-- Child object type inheriting from Shape
CREATE OR REPLACE TYPE Circle UNDER Shape (
   radius NUMBER,
   MEMBER FUNCTION area_round RETURN NUMBER,
   OVERRIDING MEMBER FUNCTION area RETURN NUMBER
);
/

-- Child type body
CREATE OR REPLACE TYPE BODY Circle AS
   MEMBER FUNCTION area_round RETURN NUMBER IS
   BEGIN
      RETURN 3.14159 * radius * radius; -- Circle area formula
   END;
END;
/

-- Test overriding
DECLARE
   s Shape := Shape('Generic Shape');
   c Circle := Circle('My Circle', 5);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Shape area: ' || s.area);   -- Calls Shape.area
   DBMS_OUTPUT.PUT_LINE('Circle area: ' || c.area);  -- Calls Circle.area
END;
/


