// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
//import "@balancer-labs/v2-solidity-utils/contracts/math/Math.sol";
import "hardhat/console.sol";

contract Heap {
    using SafeMath for uint256;

    uint[] public _orderbook;
    event removeMaxEvent(uint);
    event removeMinEvent(uint);
    event getMinEvent(uint);

    //= [30, 20, 15, 8, 10, 3, 4];

    // Inserts adds in a value to our heap.
    function insert(uint256 _value) public {
        // Add the value to the end of our array
        _orderbook.push(_value);

        // Start at the end of the array
        //uint256 currentIndex = Math.sub(_orderbook.length, 1, false);
        uint256 currentIndex = _orderbook.length.sub(1);
        // Bubble up the value until it reaches it's correct place (i.e. it is smaller than it's parent)
        while (
            currentIndex > 0 &&
            _orderbook[currentIndex.div(2)] < _orderbook[currentIndex]
        ) {
            // If the parent value is lower than our current value, we swap them
            uint temp = _orderbook[currentIndex.div(2)];
            _orderbook[currentIndex.div(2)] = _orderbook[currentIndex];
            _orderbook[currentIndex] = temp;

            // change our current Index to go up to the parent
            currentIndex = currentIndex.div(2);
        }
    }

    // RemoveMax pops off the root element of the heap (the highest value here) and rebalances the heap
    // This function is to be used when we need to find the max buy price for a new sell order
    function removeMax() public returns (uint256) {
        // Ensure the heap exists
        require(_orderbook.length > 0, "Orderbook is not initialized");

        // take the root value of the heap
        uint256 toReturn = _orderbook[0];

        // Takes the last element of the array and put it at the root
        _orderbook[0] = _orderbook[_orderbook.length.sub(1)];

        // Delete the last element from the array
        _orderbook.pop();

        // Start at the top
        uint256 currentIndex = 0;

        // Bubble down
        bubbleDown(currentIndex);

        // finally, return the top of the heap
        emit removeMaxEvent(toReturn);
        return toReturn;
    }

    function deleteOrder(uint256 _index) public {
        // Ensure the heap exists
        require(_orderbook.length > 0, "Orderbook is not initialized");
        //set the order which is deleted equal to the last element
        _orderbook[_index] = _orderbook[_orderbook.length.sub(1)];
        //delete the last element from array
        _orderbook.pop();
        // Bubble down from _index
        bubbleDown(_index);
    }

    // This function is to be used when we need to find the min sell price for a new buy order
    function removeMin() public returns (uint256) {
        require(_orderbook.length > 0, "Orderbook is not initialized");
        //(uint minElm, uint minIdx) = getMin();
        uint lastIndex = _orderbook.length.sub(1);
        uint minimumElement = _orderbook[lastIndex.div(2)];
        uint minIndex = lastIndex.div(lastIndex);

        for (uint i = lastIndex.div(lastIndex); i < _orderbook.length; ++i) {
            minimumElement = Math.min(minimumElement, _orderbook[i]);
            if (minimumElement == _orderbook[i]) {
                minIndex = i;
            }
        }

        uint256 toReturn = minimumElement;
        deleteOrder(minIndex);

        emit removeMinEvent(toReturn);
        return toReturn;
    }

    function bubbleDown(uint256 currentIndex) private {
        while (currentIndex.mul(2) < _orderbook.length.sub(1)) {
            // get the current index of the children
            // uint256 j = Math.add(Math.mul(currentIndex, 2), 1);
            uint j = currentIndex.mul(2).add(1);
            // left child value
            uint256 leftChild = _orderbook[j];
            // right child value
            uint256 rightChild = _orderbook[j.add(1)];

            // Compare the left and right child. if the rightChild is greater, then point j to it's index
            if (leftChild < rightChild) {
                j = j.add(1);
            }

            // compare the current parent value with the highest child, if the parent is greater, we're done
            if (_orderbook[currentIndex] > _orderbook[j]) {
                break;
            }

            // else swap the value
            uint tempOrder = _orderbook[currentIndex];
            _orderbook[currentIndex] = _orderbook[j];
            _orderbook[j] = tempOrder;

            // and let's keep going down the heap
            currentIndex = j;
        }
    }

    function getOrderbook() public view returns (uint[] memory) {
        return _orderbook;
    }

    function getMax() public view returns (uint256) {
        return _orderbook[0];
    }

    function getMin() public view returns (uint256 minElm) {
        uint lastIndex = _orderbook.length.sub(1);
        uint minimumElement = _orderbook[lastIndex.div(2)];
        uint minIndex = lastIndex.div(lastIndex);

        for (uint i = lastIndex.div(lastIndex); i < _orderbook.length; ++i) {
            minimumElement = Math.min(minimumElement, _orderbook[i]);
            if (minimumElement == _orderbook[i]) {
                minIndex = i;
            }
        }
        return minimumElement;
    }
}
