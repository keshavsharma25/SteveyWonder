import { useEffect } from "react";
import { Address } from "viem";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { Option } from "~~/types/steveywonder";

type Props = {
  index: number;
  option: Option;
  tba: Address | undefined;
};

export const Item = ({ index, option, tba }: Props) => {
  const { data: tokenId } = useScaffoldContractRead({
    contractName: option,
    functionName: "tokenOfOwnerByIndex",
    args: [tba, BigInt(index)],
  });

  const { tokenURI, isLoading } = useTokenURI({
    contractName: option,
    tokenId,
  });

  useEffect(() => {
    console.log(tokenURI, isLoading);
  }, [tokenURI, isLoading]);

  return <div></div>;
};
