import { useEffect, useState } from "react";
import Image from "next/image";
import { Address } from "viem";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { Option } from "~~/types/steveywonder";

type Props = {
  idx: bigint;
  option: Option;
  tba: Address | undefined;
};

export const Item = ({ idx, option, tba }: Props) => {
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const { data: tokenId } = useScaffoldContractRead({
    contractName: option,
    functionName: "tokenOfOwnerByIndex",
    args: [tba, idx],
  });

  const { tokenURI } = useTokenURI({
    contractName: option,
    tokenId,
  });

  useEffect(() => {
    if (!tokenURI) {
      setIsLoading(true);
      return;
    }

    setIsLoading(false);
  }, [tokenURI]);

  return (
    <div className="flex flex-col h-[30%] w-[30%]">
      <div className="overflow-hidden rounded-lg">
        {isLoading ? (
          <span className="bg-primary animate-pulse min-h-full min-w-full"></span>
        ) : (
          <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt={`${Number(tokenId)}`} width={420} height={420} />
        )}
      </div>
      <button className="bg-primary text-white p-2 rounded-lg">Set</button>
    </div>
  );
};
