USE PARKEASY;

-- Aggregate query 
-- Question 1 : Total Count of Parking Slots by Status:
SELECT Status, COUNT(*) as TotalSlots
FROM ParkingSlot
GROUP BY Status;
-- Inner Join
-- question 2 :	Inner Join (List of Members with their Membership Details):

SELECT m.MemberID, m.Name, mb.Name as MembershipName, mb.StartDate, mb.EndDate
FROM Member m
INNER JOIN Membership mb 
ON m.MembershipID = mb.MembershipID;

-- Nested Qery
-- question 3 :	Members Who Have Made Bookings for 'Premium' Parking Slots:

SELECT *
FROM Member
WHERE MemberID IN (SELECT MemberID FROM Booking WHERE SlotID IN 
                   (SELECT SlotID FROM ParkingSlot WHERE Type = 'Premium'));

-- Correlated Query
-- Question : 4.	Find all members who have booked a slot with a discount.
SELECT DISTINCT M.Name
FROM Member M
JOIN Vehicle V ON M.MemberID = V.MemberID
JOIN Booking B ON V.BookingID = B.BookingID
JOIN Payment P ON B.TransactionID = P.TransactionID
JOIN Membership MS ON M.MembershipID = MS.MembershipID
WHERE EXISTS (
    SELECT 1
    FROM Discount D
    JOIN Membership MS2 ON D.DiscountID = MS2.DiscountID
    WHERE MS2.MembershipID = MS.MembershipID
);


-- >= ALL / > ANY / EXISTS / NOT EXISTS Query
-- Question : 5.	Find Parking Lots with Capacity Greater Than Any 'Tech Hub' Lot:
SELECT * 
FROM ParkingLot 
WHERE Capacity > ANY (SELECT Capacity FROM ParkingLot WHERE Name LIKE '%Tech Hub%');

-- Question : 6. Find all incidents reported by members who have an active membership ?

SELECT DISTINCT I.IncidentID, I.Description
FROM Incident I
WHERE EXISTS (
    SELECT 1
    FROM Member M
    WHERE M.MemberID = I.MemberID
    AND EXISTS (
        SELECT 1
        FROM Membership MS
        WHERE MS.MembershipID = M.MembershipID
        AND MS.Status = 'Active'
    )
);


-- Set Operations (Union)
-- Question : 7.	UNION query combining information about members and admins

SELECT 'Member' AS UserType, MemberID AS ID, Name, Email, PhoneNo, Address, Username
FROM Member
UNION
SELECT 'Admin' AS UserType, AdminID AS ID, Name, Email, PhoneNo, Address, Username
FROM Admin;

-- Subqueries in SELECT and FROM
-- Question : 8. Retrieve names and email addresses of members with active membership
SELECT
    Name AS MemberName,
    Email AS MemberEmail
FROM
    Member
WHERE
    MemberID IN (
        SELECT MemberID
        FROM Membership
        WHERE Status = 'Active'
    );

-- Question : 9. Retrieve parking lot information with the average slot price using subqueries
SELECT
    PL.Name AS ParkingLotName,
    PL.Location,
    PL.Capacity,
    (
        SELECT AVG(PS.Price)
        FROM Includes I
        JOIN ParkingSlot PS ON I.SlotID = PS.SlotID
        WHERE I.LotID = PL.LotID
    ) AS AverageSlotPrice
FROM
    ParkingLot PL;
        