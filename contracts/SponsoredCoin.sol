pragma solidity >=0.5.0 <0.7.0;
// 
import "./SponsorWhitelistControl.sol";

contract SponsoredCoin {
    // minter是去minter合约的一个地址
    address public minter;
    // balances是一个mapping 这个map是从地址到每个地址余额的这么一个map
    mapping (address => uint) private balances;
    // SponsorWhiteControl是 代付白名单 的赞助者
    SponsorWhitelistControl constant private SPONSOR = SponsorWhitelistControl(address(0x0888000000000000000000000000000000000001));
    // 合约中的Sent event事件
    event Sent(address from, address to, uint amount);
    // constructor是部署合约时会运行的一个方法
    constructor() public {
        // 将msg.sender即给部署合约进行签名的地址 赋值给minter 作为合约的minter存在
        minter = msg.sender;
    }

    // mint操作
    function mint(address receiver, uint amount) public {
        // 检查mint的方法的签名者是不是minter本人 必须是minter本人才能进行mint操作
        require(msg.sender == minter);
        // mint的操作 值不能大于10的60次方
        require(amount < 1e60);
        // 如果上面两步都没问题 就会给balances的map对应的receiver 传amount这么多token
        balances[receiver] += amount;
    }

    // send操作
    function send(address receiver, uint amount) public {
        // 检查试图转的token数量是不是小于等于sender本身拥有的目前的余额 超出则会禁止转账
        require(amount <= balances[msg.sender], "Insufficient balance.");
        // 没有问题则更新该操作sender和receiver两个人的余额
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        // 最后emit这个event事件 向刚刚定义的event加入一条记录
        emit Sent(msg.sender, receiver, amount);
    }
    
    // 只读方法 返回tokenOwner所有的balance
    function balanceOf(address tokenOwner) public view returns(uint balance){
      return balances[tokenOwner];
    }
    // 代付合约中设置白名单方法
    function addPrivilege(address account) public payable {
        address[] memory a = new address[](1);
        a[0] = account;
        // 调用该合约addPrivilege时候会将同样的请求转发给sponsor的系统合约
        // 使用之前定义的sponsor 将请求转发给系统sponsor的系统合约 由系统合约来添加白名单
        SPONSOR.addPrivilege(a);
    }

    function removePrivilege(address account) public payable {
        address[] memory a = new address[](1);
        a[0] = account;
        SPONSOR.removePrivilege(a);
    }
}