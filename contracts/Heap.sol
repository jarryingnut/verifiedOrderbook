// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/math/Math.sol";
import "@balancer-labs/v2-solidity-utils/contracts/math/Math.sol";
import "hardhat/console.sol";

contract Heap {
    uint[] public _orderbook = [30, 20, 15, 8, 10, 3, 4];

    // Inserts adds in a value to our heap.
    //_value is price in the orderbook, _ref is order reference
    function insert(uint256 _value) public {
        // Add the value to the end of our array
        _orderbook.push(_value);

        // Start at the end of the array
        uint256 currentIndex = Math.sub(_orderbook.length, 1);
        // Bubble up the value until it reaches it's correct place (i.e. it is smaller than it's parent)
        while (
            currentIndex > 0 &&
            _orderbook[Math.div(currentIndex, 2, false)] <
            _orderbook[currentIndex]
        ) {
            // If the parent value is lower than our current value, we swap them
            uint temp = _orderbook[Math.div(currentIndex, 2, false)];
            _orderbook[Math.div(currentIndex, 2, false)] = _orderbook[
                currentIndex
            ];
            _orderbook[currentIndex] = temp;

            // change our current Index to go up to the parent
            currentIndex = Math.div(currentIndex, 2, false);
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
        _orderbook[0] = _orderbook[Math.sub(_orderbook.length, 1)];

        // Delete the last element from the array
        _orderbook.pop();

        // Start at the top
        uint256 currentIndex = 0;

        // Bubble down
        bubbleDown(currentIndex);

        // finally, return the top of the heap
        return toReturn;
    }

    function deleteOrder(uint256 _index) public {
        // Ensure the heap exists
        require(_orderbook.length > 0, "Orderbook is not initialized");
        //set the order which is deleted equal to the last element
        _orderbook[_index] = _orderbook[Math.sub(_orderbook.length, 1)];
        //delete the last element from array
        _orderbook.pop();
        // Bubble down from root
        bubbleDown(0);
    }

    // This function is to be used when we need to find the min sell price for a new buy order
    function removeMin() public returns (uint256) {
        require(_orderbook.length > 0, "Orderbook is not initialized");
        (uint minElm, uint minIdx) = getMin();
        uint256 toReturn = minElm;
        deleteOrder(minIdx);
        return toReturn;
    }

    function bubbleDown(uint256 currentIndex) private {
        while (Math.mul(currentIndex, 2) < Math.sub(_orderbook.length, 1)) {
            // get the current index of the children
            uint256 j = Math.add(Math.mul(currentIndex, 2), 1);

            // left child value
            uint256 leftChild = _orderbook[j];
            // right child value
            uint256 rightChild = _orderbook[Math.add(j, 1)];

            // Compare the left and right child. if the rightChild is greater, then point j to it's index
            if (leftChild < rightChild) {
                j = Math.add(j, 1);
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

    // The max heap property requires that the parent node be greater than its child node.
    // Due to this, we can conclude that a non-leaf node cannot be the minimum element as its child node has a lower value.
    // So we can narrow down our search space to only leaf nodes. In a max heap having n elements,
    // there is ceil(n/2) leaf nodes.

    function getMin() public view returns (uint256 minElm, uint256 minIdx) {
        uint lastIndex = Math.sub(_orderbook.length, 1);
        uint minimumElement = _orderbook[Math.div(lastIndex, 2, false)];
        uint minIndex = Math.div(lastIndex, 2, false);

        for (
            uint i = Math.div(lastIndex, 2, false);
            i < _orderbook.length;
            ++i
        ) {
            minimumElement = Math.min(minimumElement, _orderbook[i]);
            if (minimumElement == _orderbook[i]) {
                minIndex = i;
            }
        }

        return (minimumElement, minIndex);
    }
}