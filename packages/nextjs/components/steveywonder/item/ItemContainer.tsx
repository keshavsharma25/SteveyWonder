import { Item } from "./Item";
import { OptionType } from "./Select";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  option: OptionType;
  tokenId: bigint;
};

export const ItemContainer = ({ option, tokenId }: Props) => {
  const { data: tba } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "getTBAAddress",
    args: [tokenId],
  });

  const { data: balanceOf } = useScaffoldContractRead({
    contractName: option,
    functionName: "balanceOf",
    args: [tba],
  });

  return (
    <div className="">
      {balanceOf !== undefined &&
        tba !== undefined &&
        [...Array(balanceOf)].map((tokenIndex, index) => (
          <Item key={index} option={option} tba={tba} tokenIndex={tokenIndex} />
        ))}
    </div>
  );
};
