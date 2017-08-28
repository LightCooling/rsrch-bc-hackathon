pragma solidity ^0.4.16;
contract Build {
    struct Room {
        address ddu;
        uint8 entrance;
        uint16 floor;
    }
    
    address reestr;
    address fds;
    address zastr;
    bool public payed;
    bool public finishied;
    Room[] public rooms;

    function Build(address _fds, address _zastr, uint8[] entrances, uint16[] floors) {
        reestr = msg.sender;
        fds = _fds;
        zastr = _zastr;
        if (entrances.length != floors.length)
            revert();
        for (uint16 i = 0; i < entrances.length; i++) {
            rooms.push(Room(0, entrances[i], floors[i]));
        }
    }

    function setPayed(bool _payed) {
        if (msg.sender != fds) revert();
        payed = _payed;
    }

    function complete() {
        if (msg.sender != reestr) revert();
        finishied = true;
    }

    function createDDU(uint16 room, address buyer) returns (address)  {
        if (msg.sender != zastr) revert();
        if (rooms[room].ddu != 0) revert();
        address ddu = new DDU(reestr, zastr, buyer, room);
        rooms[room].ddu = ddu;
    }

    function cancelDDU(uint16 room) {
        if (msg.sender != rooms[room].ddu) revert();
        rooms[room].ddu = 0;
    }
}


contract DDU {
    address reestr;
    address zastr;
    address build;
    address buyer;
    uint16 room;
    bool canceling;

    function DDU(address _reestr, address _zastr, address _buyer, uint16 _room) {
        reestr = _reestr;
        zastr = _zastr;
        build = msg.sender;
        buyer = _buyer;
        room = _room;
    }

    function isOk() constant returns (bool) {
        Build _build = Build(build);
        return _build.payed();
    }

    function cancel() {
        if (msg.sender == buyer)
            canceling = true;
        else if(canceling && msg.sender == zastr) {
            Build _build = Build(build);
            _build.cancelDDU(room);
        }
    }
}
